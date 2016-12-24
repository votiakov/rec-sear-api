PkoApi::Application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  scope :api, module: :api, defaults: { format: :json } do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    # Serve websocket cable requests in-process
    # mount ActionCable.server => '/cable'


    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do

      post    '/auth/sign_in',                to: 'sessions#create'
      delete  '/auth/sign_out',                to: 'sessions#destroy'
      get     '/auth/current_user',           to: 'sessions#show'

      post 'manager_exceptions',   to: 'app_exceptions#manager'

      get :welcome, to: 'application#welcome'

      resources :users do
        post :reify, on: :member
      end
    end
  end
end
