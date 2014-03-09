if defined?(ActiveAdmin)
  ActiveAdmin.register Connect::AccessToken do
    menu parent: 'OpenID'

    index do
      column :id
      column :client
      column :account
      column :scopes do |rec|
        rec.scopes.map(&:name).join " "
      end
      column :created_at
      column :expires_at
      default_actions
    end

    controller do
      def collection
        @authorizations ||= super.includes{[client, account, scopes]}
      end
      def resource_params
        return [] if request.get?
        [params.require('connect_authorization').permit!]
      end
    end
  end
end