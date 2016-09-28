module ElderWand
  class ClientApplication
    attr_accessor :client, :client_id, :name, :client_secret, :scopes

    def self.from_hash(client, hash)
      new(client, hash)
    end

    # Initalize an ClientApplication
    #
    # @param [Client] client the ElderWand::Client instance
    # @param [Hash] opts the options to create the Application with
    # @option opts [String] :client_id the client app uid
    # @option opts [String] :client_secret the client app secret
    # @option opts [String] :name the client app name
    # @option opts [String] :secret the client app secret
    # @option opts [String] :scopes a string of scope associated to the token separated by a space
    def initialize(client, opts = {}) # rubocop:disable Metrics/AbcSize
      opts.deep_symbolize_keys!
      @client        = client
      @name          = opts.delete(:name)
      @client_id     = opts.delete(:client_id)
      @client_secret = opts.delete(:client_secret)
      @scopes        = opts.delete(:scopes) || []
      @params        = opts
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
