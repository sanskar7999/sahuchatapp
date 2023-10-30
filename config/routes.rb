Rails.application.routes.draw do
  get 'rooms/index'

  resource :registration
  resource :session
  resource :password_reset
  resource :password
  resources :confirmations, only: [:create, :edit, :new], param: :confirmation_token
  resources :rooms do
    resources :messages
  end
  resources :users

  resources :active_sessions, only: [:index, :destroy] do
    collection do
      delete "destroy_all"
    end
  end
  root "main#index"
end
