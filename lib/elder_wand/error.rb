module ElderWand
  class Error < Oauth2::Error
    attr_reader :status, :error_type, :reason

    def initialize(response)
      response.error = self
      @response      = response
      message        = []
      if response.parsed.is_a?(Hash)
        @status     = response.parsed['meta']['code']
        @error_type = response.parsed['meta']['error_type']
        @reason     = response.parsed['errors']
        message     << "#{@status}: #{@reason}"
      end

      message << response.body
      super(message.join('\n '))
    end
  end
end
