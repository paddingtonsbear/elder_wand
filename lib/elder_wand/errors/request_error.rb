module ElderWand
  module Errors
    class RequestError < ElderWandError
      def initialize(response)
        @status         = response.status
        @response       = response
        @response.error = self
        message         = []
        parsed_response = @response.parsed

        if parsed_response.is_a?(Hash)
          @error_type = parsed_response['error']
          @reasons    = parsed_response['error_description']
          message << "#{@status}: #{@reasons}"
        end

        message << response.body if message.empty?
        super(message.join('\n '))
      end
    end
  end
end
