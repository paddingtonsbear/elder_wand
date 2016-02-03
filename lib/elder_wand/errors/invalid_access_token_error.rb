module ElderWand
  module Errors
    class InvalidAccessTokenError < ElderWandError
      attr_reader :token

      def initialize(token)
        @token = token
        set_params
        super("#{error_type}: #{reason}")
      end

      def set_params
        if !token || !token.accessible?
          inaccessible_token_params
        else
          invalid_token_scope_params
        end
      end

      def inaccessible_token_params
        @status     = 403 # http status forbidden
        @error_type = :invalid_token
        @reason     = if token.try(:revoked?)
                        I18n.t('elder_wand.authorization.invalid_token.revoked')
                      elsif token.try(:expired?)
                        I18n.t('elder_wand.authorization.invalid_token.expired')
                      else
                        I18n.t('elder_wand.authorization.invalid_token.invalid')
                      end
      end

      def invalid_token_scope_params
        @status     =  401 # http status unauthorized
        @error_type = :invalid_scope
        @reason     = I18n.t('elder_wand.authorization.invalid_scope')
      end
    end
  end
end
