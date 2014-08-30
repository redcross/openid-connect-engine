if defined?(ActiveAdmin)
  ActiveAdmin.register Connect::Scope do
    menu parent: 'OpenID'

    controller do
      def resource_params
        [params.fetch(resource_request_name, {}).permit!]
      end
    end
  end
end