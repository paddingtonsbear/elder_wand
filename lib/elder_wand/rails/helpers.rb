module ElderWand
  module Rails
    module Helpers
      extend ActiveSupport::Concern
      rescue_from Oauth2::Error, with: :elder_wand_render_elder_tree_error
      rescue_from ElderWandError, with: :elder_wand_render_elder_wand_error

      # resource_owner_from_credentials do
      #   user = User.find_for_database_authentication(username: params[:username])
      #   if user && user.valid_password?(params[:password])
      #     user
      #   else
      #     fail ElderWand::Errors::InvalidPasswordError
      #   end
      # end

      # def current_resource_owner
      #   @current_resource_owner ||= User.find(elder_wand_token.resource_owner_id) if elder_wand_token
      # end

      # def authenticate_user!
      #   user = instance_eval(&Doorkeeper.configuration.resource_owner_from_credentials)
      #   create_elder_wand_token!(params[:code], user.id, ElderWand.configuration.scopes)
      # end

      def authorize_client_app!(*scopes)
        @elder_wand_scopes = scopes.presence || ElderWand.configuration.default_scopes
        if !valid_elder_tree_client?
          fail Errors::InvalidClientError
        end
      end

      def authorize_resource_owner!(*scopes)
        @elder_wand_scopes = scopes.presence || ElderWand.configuration.default_scopes
        if !valid_elder_tree_token?
          fail Errors::InvalidAccessTokenError.new(elder_wand_token)
        end
      end

      def create_elder_wand_token!(code, resource_owner_id, scopes)
        options = {
          resource_owner_id: resource_owner_id,
          scopes: scopes
        }
        @elder_wand_token = client.token_from_auth_code(code, options)
      end

      # @param [ElderWand::AccessToken]
      def elder_wand_token
        @elder_wand_token
      end

      private

      def elder_wand_client
        @elder_wand_client ||= ElderWand::Client.new(
          params[:client_id],
          params[:client_secret],
          site: Elderwand.configuration.provider_url
        )
      end

      def valid_elder_tree_token?
        @elder_wand_token = elder_wand_get_token_info
        @elder_wand_token && @elder_wand_token.acceptable?(@elder_wand_scopes)
      end

      def valid_elder_tree_client?
        @client_app = elder_wand_get_client_app_info
        @client_app && @client_app.includes_scope?(@elder_wand_scopes)
      end

      def elder_wand_get_token_info
        token = elder_wand_token_from_params || elder_wand_token_from_bearer_auth
        elder_wand_client.get_token_info(token)
      end

      def elder_wand_get_client_app_info
        elder_wand_client.get_client_info(params[:client_id], params[:client_secret])
      end

      def elder_wand_token_from_params
        params[:token]
      end

      def elder_wand_token_from_bearer_auth
        pattern = /^Bearer /i
        header  = request.authorization
        header.gsub pattern, '' if header && header.match(pattern)
      end

      # Render ElderWand::ErrorWandError
      #
      # @param [ElderWand::ErrorWandError] exception, the error raised for invalid clients or access_tokens
      def elder_wand_render_elder_wand_error(exception)
        status = exception.status
        type   = exception.error_type
        reason = exception.reason
        elder_wand_render_error_with(status, type, reason)
      end

      # Render ElderWand::Error < Oauth::Error
      #
      # @param [ElderWand::Error] exception, the error response body from ElderTree
      def elder_wand_render_elder_tree_error(exception)
        response = exception.response
        status   = response.status
        type     = exception.error_type
        reason   = exception.reason
        elder_wand_render_error_with(status, type, reason)
      end

      # Render errors with status, error_type and reasons
      #
      # @param [Fixnum] status, http response status
      # @param [Symbol] error_type, specific error type
      # @param [Array] reasons, array of error reasons
      def elder_wand_render_error_with(status, error_type, reasons)
        render content_type: 'application/json',
               status: status,
               json: {
                 meta: {
                   code: status,
                   error_type: error_type
                 },
                 errors: reasons
               }
      end
    end
  end
end
