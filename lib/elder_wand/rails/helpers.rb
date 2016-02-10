module ElderWand
  module Rails
    module Helpers
      extend ActiveSupport::Concern

      included do
        rescue_from ElderWand::Error, with: :elder_wand_render_elder_tree_error
        rescue_from ElderWand::Errors::ElderWandError, with: :elder_wand_render_elder_wand_error
      end

      # alias_method :expecto_petronum, :elder_wand_authorize_resource_owner
      # alias_method :avada_kedavra, :elder_wand_revoke_token!

      def elder_wand_authenticate_resource_owner!
        user = instance_eval(&ElderWand.configuration.resource_owner_from_credentials)
        elder_wand_create_token!(user.id, ElderWand.configuration.scopes)
      end

      def elder_wand_authorize_client_application!(*scopes)
        @elder_wand_scopes = scopes.presence || ElderWand.configuration.default_scopes
        if !valid_elder_tree_client?
          fail ElderWand::Errors::InvalidClientError
        end
      end

      def elder_wand_authorize_resource_owner!(*scopes)
        @elder_wand_scopes = scopes.presence || ElderWand.configuration.default_scopes
        if !valid_elder_tree_token?
          fail ElderWand::Errors::InvalidAccessTokenError.new(elder_wand_token)
        end
      end

      def elder_wand_revoke_token!
        token = elder_wand_token_from_params || elder_wand_token_from_bearer_auth
        elder_wand_client.revoke_token(token)
      end

      def elder_wand_create_token!(resource_owner_id, scopes)
        options = {
          resource_owner_id: resource_owner_id,
          scope: scopes.join(' ')
        }
        @elder_wand_token = elder_wand_client.token_from_password_strategy(options)
      end

      # @return [ElderWand::AccessToken]
      def elder_wand_token
        @elder_wand_token
      end

      private

      def elder_wand_client
        @elder_wand_client ||= ElderWand::Client.new(
          params[:client_id],
          params[:client_secret],
          site: ElderWand.configuration.provider_url
        )
      end

      def valid_elder_tree_token?
        @elder_wand_token ||= elder_wand_get_token_info
        @elder_wand_token && @elder_wand_token.acceptable?(@elder_wand_scopes)
      end

      def valid_elder_tree_client?
        @elder_wand_client_application ||= elder_wand_get_client_application_info
        @elder_wand_client_application && @elder_wand_client_application.includes_scope?(@elder_wand_scopes)
      end

      def elder_wand_get_token_info
        token = elder_wand_token_from_params || elder_wand_token_from_bearer_auth
        elder_wand_client.get_token_info(token)
      end

      def elder_wand_get_client_application_info
        elder_wand_client.get_client_application_info
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
        status  = exception.status
        type    = exception.error_type
        reasons = exception.reasons
        elder_wand_render_error_with(status, type, reasons)
      end

      # Render ElderWand::Error < Oauth::Error
      #
      # @param [ElderWand::Error] exception, the error response body from ElderTree
      def elder_wand_render_elder_tree_error(exception)
        response  = exception.response
        status    = response.status
        type      = exception.error_type
        reasons   = exception.reasons
        elder_wand_render_error_with(status, type, reasons)
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
