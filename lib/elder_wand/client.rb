module ElderWand
  class Client < OAuth2::Client
    # Initializes an AccessToken by making a request to the token endpoint using
    # an authentication code strategy
    #
    # @param [String] code, client application authorization code
    # @param [Hash] params a Hash of params for the token endpoint
    # @param [Class] class of access token for easier subclassing ElderWand::AccessToken
    # @return [AccessToken] the initalized AccessToken
    def token_from_auth_code(code, params = {})
      params.merge!(
        headers: {
          'Accept'       => 'application/json',
          'Content-Type' => 'application/json'
        }
      )
      auth_code.get_token(code, params)
    end

    # Initializes an AccessToken by making a request to the oauth/token/info endpoint
    #
    # @param [String] The access_token
    # @return [AccessToken] the initalized AccessToken
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

    # Initializes a ClientApplication by making a request to the oauth/application/info endpoint
    #
    # @param [String] client_id, the client application uid
    # @param [String] client_secret, the client application secret
    # @param [Class] class of client application for objectifying response from ElderTree
    # @return [ClientApplication] the initalized ClientApplication
    def get_client_info(client_id, client_secret, client_class = ClientApplication)
      opts    = {}
      app_url = '/oauth/application/info'
      opts[:headers] = {
        'Accept'       => 'application/json',
        'Content-Type' => 'application/json'
      }
      opts[:params] = {
        client_id:     client_id,
        client_secret: client_secret
      }
      opts[:raise_errors] = options[:raise_errors]

      response = request(:get, app_url, opts)
      error    = Error.new(response)
      fail(error) if options[:raise_errors] && response.status.to_s !~ /^2/
      client_class.from_hash(self, response.parsed)
    end

    # Revokes a resource owners access token
    #
    # @param [String] access_token, a resource owners access_token
    # @return [Boolean] true if revocation was successful, false otherwise
    def revoke_token(access_token)
      @options[:token_url] = '/oauth/revoke'
      @options[:token_method] = :post
      opts = {
        headers: {
          'Accept'        => 'application/json',
          'Content-Type'  => 'application/json',
          'Authorization' => "Bearer #{access_token}"
        }
      }
      opts[:raise_errors] = options[:raise_errors]
      response = request(:post, app_url, opts)
      return true if response.status.to_s =~ /^2/
      false
    end
  end
end
