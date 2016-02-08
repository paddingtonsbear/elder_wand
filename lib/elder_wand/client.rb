module ElderWand
  class Client < OAuth2::Client
    # Initializes an AccessToken by making a request to the token endpoint
    #
    # @param [Hash] params a Hash of params for the token endpoint
    # @param [Hash] access token options, to pass to the AccessToken object
    # @param [Class] class of access token for easier subclassing ElderWand::AccessToken
    # @return [AccessToken] the initalized AccessToken
    def get_token(params, access_token_opts = {}, access_token_class = AccessToken)
      opts = {}
      opts[:headers] = params.delete(:headers) || {}
      opts[:headers].merge!(json_headers)
      opts[:params]       = params
      opts[:raise_errors] = false

      response = request(options[:token_method], token_url, opts)
      error    = Errors::RequestError.new(response)
      fail(error) if !(response.status.to_s =~ /^2/ && response.parsed.is_a?(Hash) && response.parsed['access_token'])

      access_token_class.from_hash(self, response.parsed.merge(access_token_opts))
    end

    # Initializes an AccessToken by making a request to the token endpoint using
    # an authentication code strategy
    #
    # @param [String] code, client application authorization code
    # @param [Hash] params a Hash of params for the token endpoint
    # @param [Class] class of access token for easier subclassing ElderWand::AccessToken
    # @return [AccessToken] the initalized AccessToken
    def token_from_auth_code(code, params = {})
      auth_code.get_token(code, params)
    end

    # grant_type: 'password',
    # client_id: 'uid',
    # client_secret: 'invalid secret',
    # resource_owner_id: 1,
    # def token_from_password(params)
    #   params.merge!(grant_type: 'password', client_id: id, client_secret: secret)
    #   get_token(params)
    # end

    # Initializes an AccessToken by making a request to the oauth/token/info endpoint
    #
    # @param [String] The access_token
    # @return [AccessToken] the initalized AccessToken
    def get_token_info(access_token)
      @options[:token_url] = '/oauth/token/info'
      @options[:token_method] = :get
      params = { headers: { 'Authorization' => "Bearer #{access_token}" } }
      get_token(params)
    end

    # Initializes a ClientApplication by making a request to the oauth/application/info endpoint
    #
    # @param [Class] class of client application for objectifying response from ElderTree
    # @return [ClientApplication] the initalized ClientApplication
    def get_client_info(client_class = ClientApplication)
      app_info_url   = '/oauth/application/info'
      opts           = {}
      opts[:headers] = json_headers
      opts[:params]  = {
        client_id:     id,
        client_secret: secret
      }
      opts[:raise_errors] = false

      response = request(:get, app_info_url, opts)
      error    = Errors::RequestError.new(response)
      fail(error) if response.status.to_s !~ /^2/

      client_class.from_hash(self, response.parsed)
    end

    # Revokes a resource owners access token
    #
    # @param [String] access_token, a resource owners access_token
    # @return [Boolean] true if revocation was successful, false otherwise
    def revoke_token(access_token)
      revoke_url     = '/oauth/revoke'
      opts           = {}
      # opts[:params]  = { token: access_token }
      opts[:headers] = json_headers
      opts[:headers]['Authorization'] = "Bearer #{access_token}"
      opts[:raise_errors] = false

      response = request(:post, revoke_url, opts)
      return true if response.status.to_s =~ /^2/
      false
    end

    def json_headers
      {
        'Accept'       => 'application/json',
        'Content-Type' => 'application/json'
      }
    end
  end
end
