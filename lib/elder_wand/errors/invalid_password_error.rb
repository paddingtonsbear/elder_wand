module ElderWand
  module Errors
    class InvalidPasswordError < ElderWandError
      def initialize
        @status     =  401 # http status unauthorized
        @error_type = :invalid_password
        @reasons    = [I18n.t('elder_wand.authentication.invalid_password')]
        super("#{error_type}: #{reasons}")
      end
    end
  end
end
