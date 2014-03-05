module Connect
  module ControllerAdditions
    extend ActiveSupport::Concern

    included do
      include Connect::ControllerAdditions::Helper
      helper Connect::ControllerAdditions::Helper
    end

    module Helper

      def current_access_token
        @current_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      end

      def current_scopes
        token = current_access_token && token.scopes || []
      end

      def has_scope? scope
        current_scopes.detect{|s| s.name == scope}
      end

    end

    def require_user_access_token
      require_access_token
      raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(:invalid_token, 'User token is required') unless current_access_token.account
    end

    def require_client_access_token
      require_access_token
      raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(:invalid_token, 'Client token is required') if current_access_token.account
    end

    def require_access_token
      if current_access_token.nil?
        raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new
      end
      if !current_access_token.accessible? required_scopes
        raise Rack::OAuth2::Server::Resource::Bearer::Forbidden.new(:insufficient_scope)
      end
    end

    def required_scopes
      nil # as default
    end
  end
end