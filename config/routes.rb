require 'sidekiq/web'

Rails.application.routes.draw do
  post '/go' => 'initialization#provision_connect'
  get '/authenticate' => "initialization#auth"
  get '/connection_auth_complete/:id' => "initialization#connection_auth_complete"
  match 'auth/:provider/callback', to: 'organizations#auth', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]

  resources :organizations

  mount Sidekiq::Web, at: '/sidekiq'
end