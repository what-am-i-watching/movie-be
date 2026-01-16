Rails.application.routes.draw do
  resources :movies, only: [ :index, :show, :create ] do
    collection do
      get :search
    end
  end
  resources :user_movies
  devise_scope :user do
    get "/me", to: "users/sessions#show"
    get "/health", to: "health#check"
  end
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
