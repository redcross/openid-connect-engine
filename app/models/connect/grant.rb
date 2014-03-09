module Connect
  class Grant < ActiveRecord::Base
    belongs_to :client
    belongs_to :account, class_name: Connect.account_class_name
    belongs_to :scope

    before_validation :setup, on: :create

    validates :client, :account, :scope, presence: true

    include Expiring

    def self.for_client client
      where{client_id == client}
    end

    def self.for_account account
      where{account_id == account}
    end

    def self.for_scopes scopes
      where{scope_id.in scopes}
    end

    def setup
      self.expires_at = 7.days.from_now
    end
  end
end
