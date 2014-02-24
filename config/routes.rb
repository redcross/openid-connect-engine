Connect::Engine.routes.draw do
  get '.well-known/:service', as: 'discovery', to: 'discovery#show'
  get 'jwks.json', as: 'jwks', to: 'discovery#jwks'

  scope :openid do
    resources :clients, except: :show
    resources :authorizations, only: [:new, :create]
    
    match 'user_info',        to: 'user_info#show', :via => [:get, :post]

    post 'access_tokens', to: Connect::TokenEndpoint.new
  end
end
