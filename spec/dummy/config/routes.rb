Rails.application.routes.draw do
  scope 'api' do
    get  'api/client',              to: 'api#client'
    get  'api/client_with_scope',   to: 'api#client_with_scope'
    get  'api/resource',            to: 'api#resource'
    get  'api/resource_with_scope', to: 'api#resource_with_scope'
    get  'api/sigin',               to: 'api#signin'
    root to: 'api#public'
  end
end
