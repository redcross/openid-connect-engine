module Connect
  class AuthorizationRequestObject < ActiveRecord::Base
    belongs_to :authorization
    belongs_to :request_object

    include Join

    validates :authorization,  presence: true
    validates :request_object, presence: true
  end
end