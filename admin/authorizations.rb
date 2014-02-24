if defined?(ActiveAdmin)
  ActiveAdmin.register Connect::Authorization do
    menu parent: 'OpenID'

    controller do
      def resource_params
        return [] if request.get?
        [params.require('connect_authorization').permit!]
      end
    end
  end
end