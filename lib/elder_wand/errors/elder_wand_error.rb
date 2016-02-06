module ElderWand
  module Errors
    class ElderWandError < StandardError
      attr_reader :status, :error_type, :reasons, :response
    end
  end
end
