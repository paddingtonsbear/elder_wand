ElderWand.configure do
  provider_url    'http://www.example.com'
  default_scopes  :public
  # optional_scopes :write,
  #                 :cards,
  #                 :likes,
  #                 :ratings,
  #                 :friendships,
  #                 :public_lists,
  #                 :friendships_list

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_from_credentials do
    # user = User.find_for_database_authentication(username: params[:username])
    # if user && user.valid_password?(params[:password])
    #   user
    # else
    #   raise ElderWand::Errors::InvalidPasswordError
    # end
  end

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
end
