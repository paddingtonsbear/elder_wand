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
    user = User.authenticate!(params[:username], params[:password])
    if user
      user
    else
      raise ElderWand::Errors::InvalidPasswordError
    end
  end
end
