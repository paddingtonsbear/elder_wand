module ElderWand
  module Spec
    module AuthorizationHelpers
      def given_resource_owner_will_be_authenticated(resource_owner)
        ElderWand.configure do
          resource_owner_from_credentials { resource_owner }
        end

        access_token_options.merge!(resource_owner_id: resource_owner.id)
        allow(ElderWand::Client).to receive(:new).and_return elder_wand_success_client
      end

      def given_resource_owner_will_not_be_authenticated
        ElderWand.configure do
           resource_owner_from_credentials { raise ElderWand::Errors::InvalidPasswordError }
         end
        allow(ElderWand::Client).to receive(:new).and_return elder_wand_failure_client
      end

      # Stub requests made by elder_wand_authorize_resource_owner
      #
      # @param [Hash] opts the options to create the Access Token with
      # @option opts [String] token the access token value
      # @option opts [String] :refresh_token (nil) the refresh_token value
      # @option opts [FixNum] :resource_owner_id the resource owner id
      # @option opts [Array<String>] :scopes the scopes associated to the token
      # @option opts [FixNum, String] :expires_in (nil) the number of seconds in which the AccessToken will expire
      # @option opts [Boolean] :expired (false) token has expired
      # @option opts [Boolean] :revoked (false) token has been revoked
      def given_resource_owner_will_be_authorized(opts = {})
        access_token_options.merge!(opts)
        allow(ElderWand::Client).to receive(:new).and_return elder_wand_success_client
      end

      # Stub requests made by elder_wand_authorize_client_app
      #
      # @param [Hash] opts the options to create the Access Token with
      # @option opts [String] token the access token value
      # @option opts [String] :refresh_token (nil) the refresh_token value
      # @option opts [FixNum] :resource_owner_id the resource owner id
      # @option opts [Array<String>] :scopes the scopes associated to the token
      # @option opts [FixNum, String] :expires_in (nil) the number of seconds in which the AccessToken will expire
      # @option opts [Boolean] :expired (false) token has expired
      # @option opts [Boolean] :revoked (false) token has been revoked
      def given_resource_owner_will_not_be_authorized(opts = {})
        access_token_options.merge(opts)
        allow(ElderWand::Client).to receive(:new).and_return elder_wand_failure_client
      end

      # Stub requests made by elder_wand_authorize_client_app
      #
      # @param [Hash] opts the options to create the Application with
      # @option opts [String] :uid the client app uid
      # @option opts [String] :name the client app name
      # @option opts [String] :secret the client app secret
      # @option opts [Array<String>] :scopes the scopes associated to the token
      def given_client_application_will_be_authorized(opts = {})
        client_options.merge!(opts)
        allow(ElderWand::Client).to receive(:new).and_return elder_wand_success_client
      end

      # Stub requests made by elder_wand_authorize_client_app
      #
      # @param [Hash] opts the options to create the Application with
      # @option opts [String] :uid the client app uid
      # @option opts [String] :name the client app name
      # @option opts [String] :secret the client app secret
      # @option opts [Array<String>] :scopes the scopes associated to the token
      def given_client_application_will_not_be_authorized(opts = {})
        client_options.merge!(opts)
        allow(ElderWand::Client).to receive(:new).and_return elder_wand_failure_client
      end

      def elder_wand_success_client(opts = {})
        ElderWand::Client.new(client_options[:uid], client_options[:secret], site: ElderWand.configuration.provider_url) do |builder|
          builder.adapter :test do |stub|
            stub.post('/oauth/token') { |env| [201, json_header, access_token_success_body] }
            stub.get('/oauth/token/info') { |env| [200, json_header, access_token_success_body] }
            stub.get('/oauth/application/info') { |env| [200, json_header, client_application_success_body] }
            stub.post('/oauth/revoke') { |env| [200, json_header, {}] }
          end
        end
      end

      def elder_wand_failure_client
        ElderWand::Client.new(client_options[:uid], client_options[:secret], site: ElderWand.configuration.provider_url) do |builder|
          builder.adapter :test do |stub|
            stub.post('/oauth/token') { |env| [401, json_header, elder_wand_request_failure_body] }
            stub.get('/oauth/token/info') { |env| [401, json_header, elder_wand_request_failure_body] }
            stub.get('/oauth/application/info') { |env| [401, json_header, elder_wand_request_failure_body] }
            stub.post('/oauth/revoke') { |env| [401, json_header, {}] }
          end
        end
      end

      def json_header
        { 'Content-Type' => 'application/json' }
      end

      def access_token_success_body
        MultiJson.encode(access_token_options)
      end

      def client_application_success_body
        MultiJson.encode(client_options)
      end

      def elder_wand_request_failure_body
        MultiJson.encode(
          meta: {
            code: 401,
            error_type: 'invalid'
          },
          errors: ['some errors']
        )
      end

      def client_options
        @client_options ||= {
          uid: 'uid',
          name: 'name',
          secret: 'secret',
          scopes: ElderWand.configuration.scopes
        }
      end

      def access_token_options
        @access_token_options ||= {
          scopes:            ElderWand.configuration.scopes,
          revoked:           false,
          expired:           false,
          expires_in:        20,
          access_token:      'some token',
          refresh_token:     'refresh token',
          resource_owner_id: 1
        }
      end
    end
  end
end
