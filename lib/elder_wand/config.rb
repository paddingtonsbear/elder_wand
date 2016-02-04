module ElderWand
  class MissingConfiguration < StandardError
    def initialize
      super('ElderWand configuration missing. Run ElderWand initializer')
    end
  end

  def self.configure(&block)
    @config = Config::Builder.call(&block)
  end

  def self.configuration
    @config || (fail MissingConfiguration.new)
  end

  class Config
    attr_reader :default_scopes,
                :optional_scopes,
                :provider_url,
                :resource_owner_from_credentials

    def default_scopes
      @default_scopes ||= []
    end

    def optional_scopes
      @optional_scopes ||= []
    end

    def scopes
      default_scopes + optional_scopes
    end

    def resource_owner_from_credentials
      return @resource_owner_from_credentials if @resource_owner_from_credentials
      fail 'Please configure resource_owner_from_credentials block in initializers/elder_wand.rb'
    end

    class Builder
      def self.call(&block)
        new(&block).build
      end

      def initialize(&block)
        @config = Config.new
        instance_eval(&block)
      end

      def build
        @config
      end

      def provider_url(url)
        @config.instance_variable_set('@provider_url', url)
      end

      def default_scopes(*scopes)
        @config.instance_variable_set('@default_scopes', scopes)
      end

      def optional_scopes(*scopes)
        @config.instance_variable_set('@optional_scopes', scopes)
      end

      def resource_owner_from_credentials(&block)
        @config.instance_variable_set('@resource_owner_from_credentials', block)
      end
    end
  end
end
