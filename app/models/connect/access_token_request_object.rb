module Connect
  class AccessTokenRequestObject < ActiveRecord::Base
    belongs_to :access_token
    belongs_to :request_object

    include Join

    validates :access_token,   presence: true
    validates :request_object, presence: true
  end
end
