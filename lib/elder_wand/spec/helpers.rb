require 'elder_wand/spec/authorization_helpers'
require 'elder_wand/spec/config_helper'

module ElderWand
  module Spec
    module Helpers
      include ConfigHelper
      include AuthorizationHelpers
    end
  end
end
