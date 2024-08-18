Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users

  # Root path
  root to: "documents#index"

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq dashboard (make sure this is secured in production)
  require 'sidekiq/web'

  
  mount Sidekiq::Web => '/sidekiq'
  

  # Routes for documents upload and report viewing
  resources :documents, only: [:index, :new, :create, :show]
  resources :reports, only: [:index]

  resources :documents do
    member do
      get :export
    end
  end

  # Optionally, you can remove this redundant comment
  # Defines the root path route ("/")
  # root "posts#index"
end
