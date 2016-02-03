module ElderWand
  module Errors
    class InvalidClientError < ElderWandError
      def initialize
        @status     =  401 # http status unauthorized
        @error_type = :invalid_client
        @reason     = I18n.t('elder_wand.authorization.invalid_client')
        super("#{error_type}: #{reason}")
      end
    end
  end
end
