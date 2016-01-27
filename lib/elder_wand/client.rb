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

    # Retrieves information about an AccessToken
    #
    # @param [String] The access_token
    # @return [AccessToken] ElderTree::AccessToken initialized with information returned from the request
    def get_token_info(access_token)
      @options[:token_url] = '/oauth/token/info'
      @options[:token_method] = :get
      params = {
        headers: {
          'Accept'        => 'application/vnd.ditch.v1+json',
          'Content-Type'  => 'application/json',
          'Authorization' => "Bearer #{access_token}"
        }
      }
      get_token(params)
    end
  end
end

# new endpoints
#
# create auth token with user_id, client_id, client_secret,
# code
# /sessions
#
# authorize_user! *scopes
# 'Authorization: Bearer :token'
# /oauth/token/info
# *= response
# # {"resource_owner_id":1,
# # "scopes":[],
# # "expires_in_seconds":7178,
# # "application":{"uid":null},
# # "created_at":1440460991}
#
# {"access_token":"ad0b5847cb7d254f1e2ff1910275fe9dcb95345c9d54502d156fe35a37b93e80",
# "token_type":"bearer",
# "expires_in":30,
# "refresh_token":"cc38f78a5b8abe8ee81cdf25b1ca74c3fa10c3da2309de5ac37fde00cbcf2815",
# "scope":"public"}
#
# authorize_client! *scopes
# /oauth/applications/:id
# *= response
