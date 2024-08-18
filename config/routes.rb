Rails.application.routes.draw do
  devise_for :users

  root to: "documents#index"

  get "up" => "rails/health#show", as: :rails_health_check

  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  resources :documents, only: %i[index new create show destroy]

  resources :documents do
    member do
      get :export
    end
  end
end
