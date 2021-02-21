module Connect
  class AuthorizationsController < Connect::ApplicationController
    class ReauthenticationRequired < StandardError; end

    before_action :require_authentication

    rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
      @error = e
      logger.info e.backtrace[0,10].join("\n")
      render :error, status: e.status
    end

    rescue_from ReauthenticationRequired do |e|
      flash[:notice] = 'Exceeded Max Age, Login Again'
      unauthenticate!
      authentication_required!
    end

    def new
      call_authorization_endpoint
    end

    def create
      call_authorization_endpoint
    end

    private

    attr_reader :scopes, :grants

    def set_account
      @account = current_account
    end

    def allow_approval
      params[:action] == 'create'
    end

    def approved
      params[:approve]
    end

    def load_requested_scopes(req)
      @scopes = Scope.where(name: req.scope).to_a

      missing = req.scope - @scopes.map(&:name)
      missing.each do |scope|
        req.invalid_scope!("Unknown scope: #{scope}")
      end

      @scopes
    end

    def scope_ids
      scopes.map(&:id)
    end

    def load_existing_grants
      @grants = Grant.for_client(@client).for_account(@account).for_scopes(scopes).includes{scope}.to_a
    end

    def can_automatically_approve?
      return true if @client.superapp

      @missing = @scopes - @grants.map(&:scope)
      @missing.blank?
    end

    def load_request_object req
      @request_object = if (@_request_ = req.request).present?
        OpenIDConnect::RequestObject.decode req.request, @client.secret
      elsif (@request_uri = req.request_uri).present?
        OpenIDConnect::RequestObject.fetch req.request_uri, @client.secret
      end
    end

    def check_max_age request_object
      if request_object
        max_age = request_object.id_token && request_object.id_token.max_age
        last_login = Connect::Config.account_last_login.call(current_account)

        if !allow_approval && last_login < max_age.seconds.ago
          raise ReauthenticationRequired.new
        end
      end
    end

    def call_authorization_endpoint
      set_account

      rack = Rack::OAuth2::Server::Authorize.new do |req, res|
        @client = Client.find_by_identifier(req.client_id) || req.bad_request!
        @response_type = req.response_type
        res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.redirect_uris)

        if res.protocol_params_location == :fragment && req.nonce.blank?
          req.invalid_request! 'nonce required'
        end

        load_requested_scopes req
        load_existing_grants
        load_request_object req

        unless Client.available_response_types.include? Array(req.response_type).collect(&:to_s).join(' ')
          req.unsupported_response_type!
        end

        if can_automatically_approve?
          approved! req, res
        elsif allow_approval
          if approved
            approved! req, res
          else
            req.access_denied!
          end
        end
      end

      rack_response = *rack.call(request.env)

      check_max_age @request_object
      
      respond_as_rack_app *rack_response
    end

    def respond_as_rack_app(status, header, response)
      ["WWW-Authenticate"].each do |key|
        headers[key] = header[key] if header[key].present?
      end
      if response.redirect?
        redirect_to header['Location']
      else
        render :new
      end
    end

    def create_grants!
      existing_scopes = @grants.map(&:scope)

      new_scopes = scopes - existing_scopes
      new_scopes.each { |scope| Grant.create! client: @client, account: @account, scope: scope }
    end

    def approved!(req, res)
      create_grants!

      response_types = Array(req.response_type)
      if response_types.include? :code
        create_authorization_code_response req, res
      end
      if response_types.include? :token
        create_access_token_response req, res
      end
      if response_types.include? :id_token
        create_id_token_response req, res
      end
      res.approve!
    end

    def request_model
      @request_model ||= RequestObject.create!(
        jwt_string: @request_object.to_jwt(@client.secret, :HS256)
      )
    end

    def create_authorization_code_response req, res
      authorization = Authorization.create!(account: @account, client: @client, redirect_uri: res.redirect_uri, nonce: req.nonce, scope_ids: scope_ids)
      if @request_object
        authorization.create_authorization_request_object!(
          request_object: request_model
        )
      end
      res.code = authorization.code
    end

    def create_access_token_response req, res
      access_token = AccessToken.create!(account: @account, client: @client, scope_ids: scope_ids)
      if @request_object
        access_token.create_access_token_request_object!(
          request_object: request_model
        )
      end
      res.access_token = access_token.to_bearer_token
    end

    def create_id_token_response req, res
      _id_token_ = IdToken.create!(
        client: @client,
        nonce: req.nonce,
        account: @account
      )
      if @request_object
        _id_token_.create_id_token_request_object!(
          request_object: request_model
        )
      end
      res.id_token = _id_token_.to_jwt(
        code: (res.respond_to?(:code) ? res.code : nil),
        access_token: (res.respond_to?(:access_token) ? res.access_token : nil)
      )
    end
  end
end
