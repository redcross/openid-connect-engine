module Connect
  module Authentication

    class AuthenticationRequired < StandardError; end

    def self.included(klass)
      klass.send :include, Authentication::Helper
      klass.send :rescue_from, AuthenticationRequired,  with: :authentication_required!
    end

    module Helper
      def current_account
        call_config :current_user
      end

      def current_token
        @current_token
      end

      def authenticated?
        !current_account.blank?
      end
    end

    def unauthenticate!
      call_config :force_logout
    end

    def call_config name, *args
      block = Config.send name
      self.instance_exec *args, &block
    end

    def authentication_required!
      call_config :begin_login
    end

    def require_authentication
      unless authenticated?
        raise AuthenticationRequired.new
      end
    end
  end
end