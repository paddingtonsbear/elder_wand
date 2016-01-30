module ElderWand
  class Client < OAuth2::Client
    # Initializes an AccessToken by making a request to the token endpoint
    #
    # @param [Hash] params a Hash of params for the token endpoint
    # @param [Hash] access token options, to pass to the AccessToken object
    # @param [Class] class of access token for easier subclassing ElderWand::AccessToken
    # @return [AccessToken] the initalized AccessToken
    def get_token(params, access_token_opts = {}, access_token_class = AccessToken)
      super
    end

    def token_from_auth_code(code, params = {})
      params.merge!(
        headers: {
          'Accept'       => 'application/json',
          'Content-Type' => 'application/json'
        }
      )
      auth_code.get_token(code, params)
    end

    # Retrieves information about an AccessToken
    #
    # @param [String] The access_token
    # @return [AccessToken] ElderTree::AccessToken initialized with information returned from the request
    def get_token_info(access_token)
      @options[:token_url] = '/oauth/token/info'
      @options[:token_method] = :get
      params = {
        headers: {
          'Accept'        => 'application/json',
          'Content-Type'  => 'application/json',
          'Authorization' => "Bearer #{access_token}"
        }
      }
      get_token(params)
    end

    # @wip
    def get_client_info(client_id, client_secret)
    end
  end
end
