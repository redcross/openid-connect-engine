module Connect
  class Scope < ActiveRecord::Base
    has_many :access_token_scopes
    has_many :access_tokens, through: :access_token_scopes
    has_many :authorization_scopes
    has_many :authorizations, through: :authorization_scopes

    validates :name, presence: true, uniqueness: true

    def self.const_missing name
      record = self.find_by name: name.to_s.downcase
      if record
        const_set name, record
        record
      else
        super
      end
    end
  end
end
