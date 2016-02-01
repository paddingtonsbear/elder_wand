module ElderWand
  class Error < Oauth2::Error
    attr_reader :code, :error_type, :reason

    def initialize(response)
      response.error = self
      @response      = response
      message        = []
      if response.parsed.is_a?(Hash)
        @code       = response.parsed['meta']['code']
        @error_type = response.parsed['meta']['error_type']
        @reason     = response.parsed['errors']
        message     << "#{@code}: #{@reason}"
      end

      message << response.body
      super(message.join('\n '))
    end
  end
end
