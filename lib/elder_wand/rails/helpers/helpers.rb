module ElderWand
  module Rails
    module Helpers
      extend ActiveSupport::Concern
      rescue_from Oauth2::Error, with: :render_strategy_error

      def authenticate_user!
        user = User.find_for_database_authentication(username: params[:username])
        if user && user.valid_password?(params[:password])
          create_access_token!
        else
          render_invalid_password_error
        end
      end

      def authorize_client! *scopes
      end

      def authorize_user! *scopes
      end

      def create_access_token!
        @access_token = client.auth_code.get_token(params[:code])
        # client.token_from_auth_code(params[:code])
      end

      def current_resource_owner
        raise "some error if access_toke is nil"
        @current_resource_owner ||= User.find(access_token.resource_owner_id) if access_token
      end

      # def client
      #   @client ||= ElderWand::OAuth2.new
      # end

      # @return [OAuth2::AccessToken] the initalized AccessToken
      # def access_token
      #   @access_token
      # end

      def client
        @client ||= ElderWand::Client.new(
          params[:client_id],
          params[:client_secret],
          site: 'http://api.hogwarts.dev'
        )
      end

      def render_invalid_password_error
        status = 401
        render content_type: 'application/json',
               status: status,
               json: {
                 meta: {
                   code: status,
                   error_type: :invalid_password
                 },
                 errors: [I18n.t('elder_wand.authentication.invalid_password')]
               }
      end

      # @param [OAuth2::Error] exception the error response body
      def render_strategy_error(exception)
        response = exception.response
        status = response.status

        render content_type: 'application/json',
               status: response.status,
               json: response.parsed
      end
    end
  end
end

# module ElderTree
#   class RegistrationsController
#   end
# end
# steps fo registration with valid client info
# 1. find the application for the client_id and client_secret passed
# 2. check that the scope includes registrations
# 3. if it does create user
# 4. then request an access token
#
# steps for registratiosn with unauthroized client info
# 1. find the application
# 2. if it doesnt exist return a unauthorized client error

# steps for registration with invalid application scope
# 1. find application
# 2. return unauthroized error if it does not include registration scope
end
