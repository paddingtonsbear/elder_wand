module ElderWand
  class ClientApplication
    attr_accessor :client, :uid, :name, :secret, :scopes

    def self.from_hash(client, hash)
      new(client, hash)
    end

    # Initalize an ClientApplication
    #
    # @param [Client] client the ElderWand::Client instance
    # @param [Hash] opts the options to create the Application with
    # @option opts [String] :uid the client app uid
    # @option opts [String] :name the client app name
    # @option opts [String] :secret the client app secret
    # @option opts [String] :scope a string of scope associated to the token separated by a space
    def initialize(client, opts = {}) # rubocop:disable Metrics/AbcSize
      opts.deep_symbolize_keys!
      @client = client
      @uid    = opts.delete(:uid)
      @name   = opts.delete(:name)
      @secret = opts.delete(:secret)
      @scopes = scope_to_array(opts.delete(:scope))
      @params = opts
    end

    def includes_scope?(required_scopes = [])
      required_scopes.blank? || required_scopes.any? { |s| scopes.include?(s.to_s) }
    end

    private

    def scope_to_array(scope_string)
      return [] if scope_string.blank?
      scope_string.split(' ')
    end
  end
end
