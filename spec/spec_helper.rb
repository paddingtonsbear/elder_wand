ENV["RAILS_ENV"] = "test" # had to explicity state the test environment (or cucumber env.)
ENV["RAILS_ROOT"] = File.expand_path(File.dirname(__FILE__) + '/../spec/dummy/')
require File.expand_path("../dummy/config/environment", __FILE__)
# require File.expand_path(File.dirname(__FILE__) + '/../spec/dummy/config/environment')

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'elder_wand'
require 'rspec/rails'
require 'pry'
require 'json_spec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include ElderWand::Spec::Helpers
  config.include JsonSpec::Helpers
end

Faraday.default_adapter = :test

RSpec.configure do |conf|
  include ElderWand
end

VERBS = [:get, :post, :put, :delete].freeze
