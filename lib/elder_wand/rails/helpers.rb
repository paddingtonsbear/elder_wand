module ElderWand
  module Rails
    module Helpers
      extend ActiveSupport::Concern
      # @param [ElderWand::AccessToken]
      attr_reader :elder_wand_token
      rescue_from Oauth2::Error, with: :elder_wand_render_elder_tree_error

      # def authenticate_user!
      #   user = User.find_for_database_authentication(username: params[:username])
      #   if user && user.valid_password?(params[:password])
      #     create_elder_wand_token!(params[:code], user.id, ElderWand.configuration.scopes)
      #   else
      #     elder_wand_render_invalid_password_error
      #   end
      # end

      # def current_resource_owner
      #   # raise "elder_wand_token not present in request header[:authorization] or params" unless elder_wand_token
      #   # raise "not authorized user" unless elder_wand_token
      #   @current_resource_owner ||= User.find(elder_wand_token.resource_owner_id)
      # end

      def authorize_client_app!(*scopes)
        @elder_wand_scopes = scopes.presence || ElderWand.configuration.default_scopes
        if !valid_elder_tree_client?
          elder_wand_render_error(elder_wand_client_app_error)
        end
      end

      def authorize_resource_owner!(*scopes)
        @elder_wand_scopes = scopes.presence || ElderWand.configuration.default_scopes
        if !valid_elder_tree_token?
          elder_wand_render_error(elder_wand_token_error)
        end
      end

      def create_elder_wand_token!(code, resource_owner_id, scopes)
        options = {
          resource_owner_id: resource_owner_id
          scopes: scopes
        }
        @elder_wand_token = client.token_from_auth_code(code, options)
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

      def elder_wand_render_invalid_password_error
        status  = 401
        type    = :invalid_password
        reasons = [I18n.t('elder_wand.authentication.invalid_password')]
        elder_wand_render_error_with(status, type, reasons)
      end

      def elder_wand_token_error
        if elder_wand_invalid_token_response?
          ErrorWandError::AccessToken.from_access_token(elder_wand_token)
        else
          ErrorWandError::AccessToken.from_scopes
        end
      end

      def elder_wand_invalid_token_response?
        !elder_wand_token || !elder_wand_token.accessible?
      end

      def elder_wand_client_app_error
        ErrorWandError::ClientApplication.from_scopes
      end

      # Render ElderWand::ErrorWandError
      #
      # @param [ElderWand::ErrorWandError] error, the error response for invalid clients or access_tokens
      def elder_wand_render_error_response(error_response)
        status = error.status
        type   = error.error_type
        reason = error.reason
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
