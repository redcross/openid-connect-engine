if defined?(ActiveAdmin)
  ActiveAdmin.register Connect::AccessToken do
    menu parent: 'OpenID'

    filter :client
    filter :scope
    filter :created_at

    index do
      column :id
      column :client
      column :account
      column :scopes do |rec|
        rec.scopes.map(&:name).join " "
      end
      column :created_at
      column :expires_at
      actions
    end

    controller do
      def collection
        @authorizations ||= super.includes(:client, :account, :scopes)
      end
      def resource_params
        [params.fetch(resource_request_name, {}).permit!]
      end
    end
  end
end