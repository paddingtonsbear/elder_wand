module ElderWand
  class MissingConfiguration < StandardError
    def initialize
      super('ElderWand configuration missing. Run ElderWand initializer')
    end
  end

  def self.configure(&block)
    @config = Config.new(&block)
  end

  def self.configuration
    @config || (fail MissingConfiguration.new)
  end

  class Config
    attr_reader :default_scopes, :optional_scopes

    def initialize(&block)
      instance_eval(&block)
    end

    def default_scopes(*scopes)
      @default_scopes = scopes
    end

    def optional_scopes(*scopes)
      @optional_scopes = scopes
    end

    def scopes
      default_scopes + optional_scopes
    end
  end
end
