$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "elder_wand/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "elder_wand"
  s.version     = ElderWand::VERSION
  s.authors     = ["Elom Gomez"]
  s.email       = ["gomezelom@yahoo.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ElderWand."
  s.description = "TODO: Description of ElderWand."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.5.1"

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails', '~> 3.4.0'
end
