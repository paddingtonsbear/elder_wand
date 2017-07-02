$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'elder_wand/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'elder_wand'
  s.version     = ElderWand::VERSION
  s.authors     = ['Elom Gomez']
  s.email       = ['gomezelom@yahoo.com']
  s.homepage    = ''
  s.summary     = 'A gem that allows a Rails Api to interact with Elder Tree (Oauth Provider).'
  s.description = 'A gem that allows a Rails Api to interact with Elder Tree (Oauth Provider).'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 5.1'
  s.add_dependency 'oauth2', '~> 1.1.0'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'json_spec', '>= 1.1.4'
  s.add_development_dependency 'database_cleaner', '~> 1.5.1'
end
