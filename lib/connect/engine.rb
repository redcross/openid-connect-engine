module Connect
  class Engine < ::Rails::Engine
    isolate_namespace Connect

    initializer "connect.middleware" do |app|
      app.config.middleware.use Rack::OAuth2::Server::Resource::Bearer, 'OpenID Connect' do |req|
        AccessToken.valid.find_by(token: req.access_token) || req.invalid_token!
      end
      app.config.middleware.use Rack::OAuth2::Server::Resource::MAC, 'OpenID Connect' do |req|
        AccessToken.valid.find_by(token: req.access_token) || req.invalid_token!
      end
    end

    initializer 'activeservice.autoload', :before => :set_autoload_paths do |app|
      app.config.autoload_paths << "#{config.root}/lib"
      app.config.paths["db/migrate"] << "#{config.root}/db/migrate"
    end

    initializer "mime" do
      Mime::Type.register 'application/jrd+json', :jrd
    end

    initializer "activeadmin" do
      if defined?(ActiveAdmin)
        ActiveAdmin.application.load_paths.unshift "#{config.root}/admin"
      end
    end
  end
end
