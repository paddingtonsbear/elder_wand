module ElderWand
  class ApplicationController < ActionController::API
    before_action :require_json
    rescue_from Oauth2::Error, with: :render_strategy_error

    protected

    def require_json
      return if request.format.json?

      head :not_acceptable
      false
    end

    def authenticate_user!
      user = User.find_for_database_authentication(username: params[:username])
      if user && user.valid_password?(params[:password])
        fetch_access_token
      else
        render_invalid_password_error
      end
    end

    # def client_strategy_authorize!
    # end

    def authorize_client!
    end

    def authorize_user!
    end

    def elder_wand_authorize!(scope = nil)
    end

    def current_resource_owner
      @current_resource_owner ||= User.find(access_token.resource_owner_id) if access_token
    end

    # @return [OAuth2::AccessToken] the initalized AccessToken
    def access_token
      @access_token
    end

    def fetch_access_token
      @access_token ||= client.auth_token.get_token(params[:code])
    end

    def client
      @client ||= OAuth2::Client.new(
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

    @param [OAuth2::Error] exception the error response body
    def render_strategy_error(exception)
      response = exception.response
      status = response.status

      render content_type: 'application/json',
             status: response.status,
             json: response.parsed
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
