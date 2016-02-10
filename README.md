<img src="http://vignette3.wikia.nocookie.net/harrypotter/images/6/63/Tumblr_m4eabyXx1j1qcd6r7o2_r1_250.gif/revision/latest?cb=20140311030944" width="300">

# ElderWand

>The Elder Wand is one of the fabled Deathly Hallows. In "The Tale of the Three Brothers"
it was the first Hallow created, bestowed on Antioch Peverell, supposedly by Death himself
after the wizard requested, as his bounty, the most powerful wand in the history of wizardkind.

A Ruby wrapper for the [ElderTree OAuth 2.0](https://github.com/paddingtonsbear/elder_tree) Provider.

## Installation
Put this in your Gemfile:
```ruby
gem 'elder_wand'
```

Run the installation generator with:
```
rails generate elder_wand:install
```

This will install the ElderWand initializer into `config/initializers/elder_wand.rb`.

## Resources
* [OAuth2 gem](https://github.com/intridea/oauth2)
* [Doorkeeper gem](https://github.com/doorkeeper-gem/doorkeeper)

## Table of Contents
- [Configuration](#configuration)
  - [Authentication](#authentication)
- [Protecting resources with ElderWand](#protecting-resources-with-elderwand)
  - [Access Token Scopes](#access-token-scopes)
  - [Authenticated Resource Owner](#authenticated-resource-owner)
- [Using the ElderWand::Client](#using-the-elderwandclient)
- [ElderWand Errors](#elderwand-errors)
- [Testing](#testing)
  - [RSpec](#rspec)
  - [Cucumber](#cucumber)
- [License](#license)

## Configuration
###Authentication
You need to configure ElderWand in order to access the resource_owner by adding an authentication block in `initializers/elder_wand.rb`.
```ruby
ElderWand.configure do
  resource_owner_from_credentials do
    user = User.find_for_database_authentication(username: params[:username])
    if user && user.valid_password?(params[:password])
      user
    else
      raise ElderWand::Errors::InvalidPasswordError
    end
  end
end
```

## Protecting Resources with ElderWand
To protect your API with ElderWand, you just need to setup `before_action`'s specifying the actions you want to protect.
eg.
```ruby
class ExampleController < ApplicationController
  before_action :elder_wand_authorize_resource_owner! # requires access_tokens for all actions
  before_action :elder_wand_authorize_client_app! # requires client_id and client_secret for all actions,
                                                  # this is mainly for communication between internal services
  # actions
end
```
### Access Token Scopes
You can also require the access token to have specific scopes in certain actions:

First configure the scopes in `elder_wand/elder_wand.rb`
```ruby
ElderWand.configure do
  default_scopes :public # if no scope was requested, this will be the default
  optional_scopes :like, :rate
end
```

And in controllers
```ruby
class ExampleController < ApplicationController
  before_action -> { elder_wand_authorize_resource_owner! :public }, only: :index
  before_action only: [:create, :update, :destroy] do
    elder_wand_authorize_resource_owner! :like, :rate
  end
end
```
### Authenticated Resource Owner
If you want to return data based on the current resource owner, in other words, the access token owner,
you may want to define a method in your controller that returns the resource owner instance:
```ruby
class SessionsController < ApplicationController
  before_action :elder_wand_authenticate_resource_owner!

  private

  # Find the user that owns the access token
  def current_resource_owner
    User.find(elder_wand_token.resource_owner_id) if elder_wand_token
  end
end
```

## Using the ElderWand::Client
```ruby
require 'elder_wand'

client = ElderWand::Client.new('client_id', 'client_secret', :site => 'https://example.org')
# ElderWand::AccessToken
access_token = client.token_from_auth_code('auth_code',
                 { redirect_url: 'http://localhost:8080/oauth2/callback' })
# ElderWand::ClientApplication
client_application = client.get_client_info
```

## ElderWand Errors
List of all errors
* [ElderWandError](https://github.com/paddingtonsbear/elder_wand/blob/master/lib/elder_wand/errors/elder_wand_error.rb)
* [InvalidAccessToken](https://github.com/paddingtonsbear/elder_wand/blob/master/lib/elder_wand/errors/invalid_access_token_error.rb)
* [InvalidClientError](https://github.com/paddingtonsbear/elder_wand/blob/master/lib/elder_wand/errors/invalid_client_error.rb)
* [InvalidPasswordError](https://github.com/paddingtonsbear/elder_wand/blob/master/lib/elder_wand/errors/invalid_password_error.rb)
* [RequestError](https://github.com/paddingtonsbear/elder_wand/blob/master/lib/elder_wand/errors/request_error.rb)

Add the following helpers to your controllers to handle errors
```ruby
class ApiController < ApplicationController
  rescue_from ElderWand::Error, with: :elder_wand_render_elder_tree_error
  rescue_from ElderWand::Errors::ElderWandError, with: :elder_wand_render_elder_wand_error
end
```

## Testing
This gem includes test helpers that stub all requests made to [ElderTree](https://github.com/paddingtonsbear/elder_tree). These helpers
include:
* `given_access_token_will_be_revoked`
* `given_access_token_will_not_be_revoked`
* `given_resource_owner_will_be_authenticated(opts = {})`
* `given_resource_owner_will_not_be_authenticated`
* `given_resource_owner_will_be_authorized(opts = {})`
* `given_resource_owner_will_not_be_authorized(opts = {})`
* `given_client_application_will_be_authorized(opts = {})`
* `given_client_application_will_not_be_authorized(opts = {})`

information about each helper can be found [here](https://github.com/paddingtonsbear/elder_wand/blob/master/lib/elder_wand/spec/authorization_helpers.rb)

### RSpec
```ruby
RSpec.configure do |config|
  config.include ElderWand::Spec::Helpers
end
```

### Cucumber
```ruby
World(ElderWand::Spec::Helpers)
```

##License
MIT License. Copyright 2016 Sight Labs LLC.
