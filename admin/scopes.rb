if defined?(ActiveAdmin)
  ActiveAdmin.register Connect::Scope do
    menu parent: 'OpenID'

    controller do
      def resource_params
        return [] if request.get?
        [params.require('connect_scope').permit!]
      end
    end
  end
end