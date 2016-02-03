module ElderWand
  module Errors
    class RequestError < ElderWandError
      def intialize(response)
        @status         = response.status
        @response       = response
        @response.error = self
        message         = []
        parsed_response = @response.parsed


        if parsed_response.is_a?(Hash)
          if parsed_response['meta']
            @error_type = parsed_response['meta']['error_type']
          end
          @reason     = parsed_response['errors']
          message     << "#{@status}: #{@reason}"
        end

        message << response.body if message.empty?
        super(message.join('\n '))
      end
    end
  end
end
