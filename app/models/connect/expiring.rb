module Connect
  module Expiring
    extend ActiveSupport::Concern

    module ClassMethods
      def valid
        where{expires_at >= Time.now}
      end

      def expired time
        where { expires_at <= time }
      end
    end
  end
end