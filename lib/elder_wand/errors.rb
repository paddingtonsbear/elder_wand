module ElderWand
  module Errors
    class ElderWandError < StandardError
    end

    class InvalidAccessToken < ElderWandError
    end

    class InvalidAuthorizationStrategy < ElderWandError
    end

    class InvalidPasswordError < ElderWandError
    end
  end
end
