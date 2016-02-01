module ElderWand
  module ErrorWandError
    class Base
      attr_reader :status, :reason, :error_type
      def initialize(status, error_type, reason)
        @status     = status
        @reason     = reason
        @error_type = error_type
      end
    end

    class AccessToken < Base
      def self.from_access_token(access_token)
        status     = 403 # http status forbidden
        error_type = :invalid_token
        reason     = if access_token.try(:revoked?)
                       'The access token was revoked.'
                     elsif access_token.try(:expired?)
                       'The access token expired.'
                     else
                       'The access token is invalid.'
                     end
        new(status, error_type, reason)
      end

      def self.from_scopes
        status     =  401 # http status unauthorized
        error_type = :invalid_scope
        reason     = 'The requested scope is invalid, unknown, or malformed.'
        new(status, error_type, reason)
      end
    end

    class ClientApplication < Base
      def self.from_scopes
        status     =  401 # http status unauthorized
        error_type = :invalid_client
        reason     = 'The client is not authorized to perform this request using this method.'
        new(status, error_type, reason)
      end
    end
  end
end
