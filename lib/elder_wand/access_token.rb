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
    # @option opts [String] :scope a string of scope associated to the token separated by a space
    # @option opts [FixNum, String] :expires_in_seconds (nil) the number of seconds in which the AccessToken will expire
    # @option opts [FixNum, String] :expires_at (nil) the epoch time in seconds in which AccessToken will expire
    # @option opts [Boolean] :expired (false) token has expired
    # @option opts [Boolean] :revoked (false) token has been revoked
    #    Access Token value in :body or :query transmission mode
    def initialize(client, token, opts = {}) # rubocop:disable Metrics/AbcSize
      opts.deep_symbolize_keys!
      @client            = client
      @token             = token.to_s
      @scopes            = scope_to_array(opts.delete(:scope))
      @expires_in        = opts.delete(:expires_in_seconds)
      @expires_in      ||= opts.delete(:expires_in)
      @expires_in      &&= @expires_in.to_i
      @expires_at        = Time.now.to_i + @expires_in if @expires_in
      @expired           = opts.delete(:expired) || false
      @revoked           = opts.delete(:revoked) || false
      @refresh_token     = opts.delete(:refresh_token)
      @resource_owner_id = opts.delete(:resource_owner_id)
      @params            = opts
    end

    def acceptable?(scopes)
      accessible? && includes_scope?(*scopes)
    end

    def includes_scope?(*required_scopes)
      required_scopes.blank? || required_scopes.any? { |s| scopes.include?(s.to_s) }
    end

    def accessible?
      !expired? && !revoked?
    end

    private

    def scope_to_array(scope_string)
      return [] if scope_string.blank?
      scope_string.split(' ')
    end
  end
end
