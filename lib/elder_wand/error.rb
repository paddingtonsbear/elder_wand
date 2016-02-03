# this class will be called instead of OAuth2::Error
# when http requests fail
module ElderWand
  class Error < StandardError
    attr_reader :status, :error_type, :reason, :response

    def initialize(response)
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
