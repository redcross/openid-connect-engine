module Connect
  class IdToken < ActiveRecord::Base
    belongs_to :account, class_name: Connect.account_class_name
    belongs_to :client
    has_one :id_token_request_object, dependent: :destroy
    has_one :request_object, through: :id_token_request_object

    before_validation :setup, on: :create

    validates :account, presence: true
    validates :client,  presence: true

    include Expiring

    def subject_identifier
      SubjectIdentifier.new(client, account).identifier
    end

    def to_response_object(with = {})
      claims = {
        iss: self.class.config[:issuer],
        sub: subject_identifier,
        aud: client.identifier,
        nonce: nonce,
        exp: expires_at.to_i,
        iat: created_at.to_i
      }
      if accessible?(:auth_time)
        claims[:auth_time] = Config.account_last_login.call(account).try :to_i
      end
      if accessible?(:acr)
        required_acr = request_object.to_request_object.id_token.claims[:acr].try(:[], :values)
        if required?(:acr) && required_acr && !required_acr.include?('0')
          # TODO: return error, maybe not this place though.
        end
        claims[:acr] = '0'
      end
      id_token = OpenIDConnect::ResponseObject::IdToken.new(claims)
      id_token.code = with[:code] if with[:code]
      id_token.access_token = with[:access_token] if with[:access_token]
      id_token
    end

    def to_jwt(with = {})
      to_response_object(with).to_jwt self.class.config[:private_key]
    end

    private

    def required?(claim)
      request_object.try(:to_request_object).try(:id_token).try(:required?, claim)
    end

    def accessible?(claim)
      request_object.try(:to_request_object).try(:id_token).try(:accessible?, claim)
    end

    def setup
      self.expires_at = 6.hours.from_now
    end

    class << self
      def decode(id_token)
        OpenIDConnect::ResponseObject::IdToken.decode id_token, config[:public_key]
      rescue => e
        logger.error e.message
        nil
      end

      def config
        unless @config
          @config = {issuer: Config.jwt_issuer}
          @config[:jwks_uri] = File.join(@config[:issuer], 'jwks.json')
          private_key = OpenSSL::PKey::RSA.new(
            Config.private_key,
            Config.private_key_password
          )
          cert = OpenSSL::X509::Certificate.new(
            Config.certificate
          )
          @config[:public_key]  = cert.public_key
          @config[:private_key] = private_key
          @config[:jwk_set] = JSON::JWK::Set.new(
            JSON::JWK.new(cert.public_key, use: :sig)
          )
        end
        @config
      end
    end
  end
end
