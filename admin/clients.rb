if defined?(ActiveAdmin)
  ActiveAdmin.register Connect::Client do
    menu parent: 'OpenID'

    filter :name
    filter :identifier
    filter :dynamic

    index do
      column :id
      column :name
      column :identifier
      column :jwks_uri
      column :sector_identifier
      column :native
      column :dynamic
      column :ppid
      column :expires_at
      actions
    end

    show do 
      attributes_table do
        row :account
        row :id
        row :name
        row :identifier
        row :secret
        row :jwks_uri
        row :sector_identifier
        row :redirect_uris do |rec|
          safe_join rec.redirect_uris, tag(:br)
        end
        row :native
        row :dynamic
        row :ppid
        row :superapp
        row :expires_at
        row :raw_registered_json
        row :authorization_endpoint do connect.new_authorization_url; end
        row :token_endpoint do connect.access_tokens_url; end
        row :userinfo_endpoint do connect.user_info_url; end
      end
    end

    form do |f|
      f.inputs do 
        f.input :account
        f.input :name
        f.input :jwks_uri
        f.input :sector_identifier
        f.input :native
        f.input :dynamic
        f.input :ppid
        f.input :superapp
        f.input :expires_at
        f.input :redirect_uri, input_html: {value: f.object.redirect_uris.try(:first)}
      end
      f.actions
    end

    controller do
      def resource_params
        [params.fetch(resource_request_name, {}).permit!]
      end
    end
  end
end