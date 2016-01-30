module ElderWand
  module Rails
    module Helpers
      attr_reader :access_token # [OAuth2::AccessToken]
      extend ActiveSupport::Concern
      rescue_from Oauth2::Error, with: :elder_wand_render_strategy_error

      def authenticate_user!
        user = User.find_for_database_authentication(username: params[:username])
        if user && user.valid_password?(params[:password])
          @access_token = elder_wand_create_access_token!(params[:code], user.id, ElderTree.configuration.scopes)
        else
          elder_wand_render_strategy_error_with()
        end
      end

      def authorize_client!(*scopes)
        @elder_tree_scopes = scopes.presence || ElderWand.configuration.default_scopes
        valid_elder_tree_client?
      end

      def authorize_user!(*scopes)
        @elder_tree_scopes = scopes.presence || ElderWand.configuration.default_scopes
        valid_elder_tree_token?
      end

      def current_resource_owner
        # raise "access_token not present in request header[:authorization] or params" unless access_token
        # raise "not authorized user" unless access_token
        raise ElderWand::Errors::InvalidAccessToken unless access_token
        @current_resource_owner ||= User.find(access_token.resource_owner_id)
      end

      def elder_wand_create_access_token!(code, resource_owner_id, scopes)
        options = {
          resource_owner_id: resource_owner_id
          scopes: scopes
        }
        client.token_from_auth_code(code, options)
      end

      private

      def elder_wand_client
        @elder_wand_client ||= ElderWand::Client.new(
          params[:client_id],
          params[:client_secret],
          site: 'http://api.hogwarts.dev'
        )
      end

      def valid_elder_tree_token?
        @access_token = elder_wand_get_token_info
        @access_token && @access_token.acceptable?(@elder_tree_scopes)
      end

      def valid_elder_tree_client?
        @client_app = elder_wand_get_client_app_info
        # @client_app && @client_app.acceptable?(@elder_tree_scopes)
      end

      def elder_wand_get_token_info
        token = elder_wand_token_from_params || elder_wand_token_from_bearer_auth
        elder_wand_client.get_token_info(token)
      end

      def elder_wand_token_from_params
        params[:token]
      end

      def elder_wand_token_from_bearer_auth
        pattern = /^Bearer /i
        header  = request.authorization
        header.gsub pattern, '' if match_header_pattern?(header, pattern)
      end

      def match_header_pattern?(header, pattern)
        header && header.match(pattern)
      end

      def elder_wand_render_invalid_password_error
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
      def elder_wand_render_strategy_error(exception)
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
