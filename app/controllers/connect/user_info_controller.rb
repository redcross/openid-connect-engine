module Connect
  class UserInfoController < Connect::ApplicationController
    before_filter :require_user_access_token

    def show
      acct = current_token.account

      keys = []
      keys += [:name, :given_name, :family_name, :preferred_username] if current_token.accessible? 'profile'
      keys += [:email] if current_token.accessible? 'email'



      attrs = Config.account_attributes.call(acct, keys, current_token.scopes)
      attrs['sub'] = SubjectIdentifier.new(current_token.client, acct).identifier

      render json: attrs
    end

    private

    def required_scopes
      Scope::OPENID
    end
  end
end
