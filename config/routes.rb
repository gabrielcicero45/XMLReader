Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users

  # Root path
  root to: 'documents#index'

  # Health check route
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Sidekiq dashboard (make sure this is secured in production)
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  resources :documents, only: %i[index new create show destroy]

  resources :documents do
    member do
      get :export
    end
  end
end
