require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class ElderTree < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, 'elder_tree'

      CUSTOM_PROVIDER_URL = ENV['AUTH_PROVIDER_URL'] || "http://custom-provider-goes-here"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        site:             CUSTOM_PROVIDER_URL,
        authorize_url:    "#{CUSTOM_PROVIDER_URL}/oauth/authorize",
        access_token_url: "#{CUSTOM_PROVIDER_URL}/oauth/token"
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid{ raw_info['id'] }

      info do
        {
          :name => raw_info['name'],
          :email => raw_info['email']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/me').parsed
      end
    end
  end
end
