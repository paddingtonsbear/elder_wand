module ElderWand
  class AccessToken < OAuth2::AccessToken
    attr_accessor :resource_owner_id, :scopes, :revoked, :expired
    alias_method :revoked?, :revoked
    alias_method :expired?, :expired

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
      @scopes            = opts.delete(:scopes) || opts.delete('scopes') || []
      @expires_in        = opts.delete(:expires_in_seconds) || opts.delete('expires_in_seconds')
      @expires_in      ||= opts.delete(:expires_in) || opts.delete(:expires_in)
      @expires_in      &&= @expires_in.to_i
      @expires_at        = Time.now.to_i + @expires_in if @expires_in
      @expired           = opts.delete(:expired) || false
      @revoked           = opts.delete(:revoked) || false
      @refresh_token     = opts.delete(:refresh_token) || opts.delete('refresh_token')
      @resource_owner_id = opts.delete(:resource_owner_id) || opts.delete('resource_owner_id')
      @params            = opts
    end

    def acceptable?(scopes)
      accessible? && includes_scope?(*scopes)
    end

    def includes_scope?(*required_scopes)
      required_scopes.blank? || required_scopes.any? { |s| scopes.include?(s.to_s) }
    end

    private

    def accessible?
      !expired? && !revoked?
    end
  end
end
