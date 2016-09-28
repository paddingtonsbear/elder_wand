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
      opts[:raise_errors] = false

      if options[:token_method] == :post
        opts[:body] = params
        opts[:headers]['Content-Type'] = 'application/x-www-form-urlencoded'
      else
        opts[:params] = params
      end

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
    # @return [AccessToken] the initalized AccessToken
    def token_from_auth_code(code, params = {})
      auth_code.get_token(code, params)
    end

    # Initializes an AccessToken by making a request to the token endpoint using
    # a password strategy
    #
    # @param [String] code, client application authorization code
    # @param [Hash] params a Hash of params for the token endpoint
    # @option params [Array<String>] :scope the scopes to be associated with the token
    # @option params [FixNum, String] :resource_owner_id the owner of the resource id
    # @return [AccessToken] the initalized AccessToken
    def token_from_password_strategy(params = {})
      params.merge!(grant_type: 'password', client_id: id, client_secret: secret)
      get_token(params)
    end

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

    # Initializes an ClientApplication by making a request to create a client application
    #
    # @param params [String] :name the name of the client application
    # @param params [URI] :redirect_uri the redirect uri of the client application
    # @param params [Array<String>] :scopes the scopes to be associated with the client application
    # @return [ClientApplication] the initalized ClientApplication
    def create_application(params)
      app_info_url   = '/oauth/applications'
      opts           = {}
      opts[:headers] = json_headers
      opts[:params]  = params
      opts[:raise_errors] = false

      response = request(:post, app_info_url, opts)
      error    = Errors::RequestError.new(response)
      fail(error) if response.status.to_s !~ /^2/

      ClientApplication.from_hash(self, response.parsed)
    end

    # Initializes a ClientApplication by making a request to the oauth/application/info endpoint
    #
    # @param [Class] class of client application for objectifying response from ElderTree
    # @return [ClientApplication] the initalized ClientApplication
    def get_client_application_info(client_class = ClientApplication)
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
      opts[:headers] = json_headers
      opts[:headers]['Authorization'] = "Bearer #{access_token}"
      opts[:headers]['Content-Type'] = 'application/x-www-form-urlencoded'
      opts[:body]    = {
        token:         access_token,
        client_id:     id,
        client_secret: secret
      }
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
