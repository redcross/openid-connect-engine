module Connect
  class AuthorizationEndpoint
    attr_accessor :app, :account, :client, :redirect_uri, :response_type, :scopes, :_request_, :request_uri, :request_object
    delegate :call, to: :app

    def initialize(current_account, allow_approval = false, approved = false)
      @account = current_account
      @app = Rack::OAuth2::Server::Authorize.new do |req, res|
        @client = Client.find_by_identifier(req.client_id) || req.bad_request!
        res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.redirect_uris)
        if res.protocol_params_location == :fragment && req.nonce.blank?
          req.invalid_request! 'nonce required'
        end
        @scopes = Scope.where(name: req.scope).group_by(&:name)
        @scopes = req.scope.inject([]) do |_scopes_, scope|
          _scopes_ << (@scopes[scope].try(:first) || req.invalid_scope!("Unknown scope: #{scope}"))
        end

        @grants = Grant.for_client(@client).for_account(@account).for_scopes(scopes).includes{scope}.to_a

        @request_object = if (@_request_ = req.request).present?
          OpenIDConnect::RequestObject.decode req.request, @client.secret
        elsif (@request_uri = req.request_uri).present?
          OpenIDConnect::RequestObject.fetch req.request_uri, @client.secret
        end
        if Client.available_response_types.include? Array(req.response_type).collect(&:to_s).join(' ')
          if allow_approval
            if approved
              approved! req, res
            else
              req.access_denied!
            end
          else
            @response_type = req.response_type
          end
        else
          req.unsupported_response_type!
        end
      end
    end

    
  end
end