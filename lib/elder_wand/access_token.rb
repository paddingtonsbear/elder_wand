module ElderWand
  class AccessToken < OAuth2::AccessToken
    attr_accessor :resource_owner_id, :scopes

    # Initalize an AccessToken
    #
    # @param [Client] client the OAuth2::Client instance
    # @param [String] token the Access Token value
    # @param [Hash] opts the options to create the Access Token with
    # @option opts [String] :refresh_token (nil) the refresh_token value
    # @option opts [Array<String>] :scopes the scopes associated to the token
    # @option opts [FixNum, String] :expires_in_seconds (nil) the number of seconds in which the AccessToken will expire
    # @option opts [FixNum, String] :expires_at (nil) the epoch time in seconds in which AccessToken will expire
    # @option opts [Symbol] :mode (:header) the transmission mode of the Access Token parameter value
    #    one of :header, :body or :query
    # @option opts [String] :header_format ('Bearer %s') the string format to use for the Authorization header
    # @option opts [String] :param_name ('access_token') the parameter name to use for transmission of the
    #    Access Token value in :body or :query transmission mode
    def initialize(client, token, opts = {}) # rubocop:disable Metrics/AbcSize
      @client            = client
      @token             = token.to_s
      @scopes            = opts.delete(:scopes) || opts.delete('scopes')
      @expires_in        = opts.delete(:expires_in_seconds) || opts.delete('expires_in_seconds')
      @expires_in      ||= opts.delete(:expires_in) || opts.delete(:expires_in)
      @expires_in      &&= @expires_in.to_i
      @expires_at        = Time.now.to_i + @expires_in if @expires_in
      @refresh_token     = opts.delete(:refresh_token) || opts.delete('refresh_token')
      @resource_owner_id = opts.delete(:resource_owner_id) || opts.delete('resource_owner_id')

      @options = {:mode          => opts.delete(:mode) || :header,
                  :header_format => opts.delete(:header_format) || 'Bearer %s',
                  :param_name    => opts.delete(:param_name) || 'access_token'}
      @params = opts
    end
  end
end

# {"resource_owner_id":1,
# "scopes":[],
# "expires_in_seconds":7178,
# "application":{"uid":null},
# "created_at":1440460991}

# {"access_token":"ad0b5847cb7d254f1e2ff1910275fe9dcb95345c9d54502d156fe35a37b93e80",
# "token_type":"bearer",
# "expires_in":30,
# "refresh_token":"cc38f78a5b8abe8ee81cdf25b1ca74c3fa10c3da2309de5ac37fde00cbcf2815",
# "scope":"public"}
