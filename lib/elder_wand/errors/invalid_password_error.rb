module ElderWand
  module Errors
    class InvalidPasswordError < ElderWandError
      def initialize
        @status     =  401 # http status unauthorized
        @error_type = :invalid_password
        @reason     = I18n.t('elder_wand.authentication.invalid_password')
        super("#{error_type}: #{reason}")
      end
    end
  end
end
