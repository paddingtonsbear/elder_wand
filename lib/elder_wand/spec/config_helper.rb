module ElderWand
  module Spec
    module ConfigHelper
      def config_is_set(setting, valud = nil, &block)
        setting_ivar = "@#{setting}"
        value = block_given? ? block : value
        ElderWand.configuration.instance_variable_set(setting_ivar, value)
      end
    end
  end
end
