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
    #   raise Doorkeeper::Errors::InvalidPasswordError
    # end
  end
end
