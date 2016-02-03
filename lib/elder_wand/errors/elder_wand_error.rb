module ElderWand
  module Errors
    class ElderWandError < StandardError
      attr_reader :status, :error_type, :reason, :response
    end
  end
end
