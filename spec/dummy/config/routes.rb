Rails.application.routes.draw do
  get  'client',              to: 'api#client'
  get  'client_with_scope',   to: 'api#client_with_scope'
  get  'resource',            to: 'api#resource'
  get  'resource_with_scope', to: 'api#resource_with_scope'
  get  'signin',              to: 'api#signin'
  root to: 'api#public'
end
