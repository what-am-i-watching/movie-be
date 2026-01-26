Rails.application.routes.draw do
  # Swagger UI (development only - rswag gems are in development group)
  if defined?(Rswag::Ui::Engine) && defined?(Rswag::Api::Engine) && !Rails.env.production?
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end

  resources :movies, only: [ :index, :show, :create ] do
    collection do
      get :search
      get :popular
      get "details/:tmdb_id", to: "movies#details"
    end
  end
  resources :user_movies
  devise_scope :user do
    get "/me", to: "users/sessions#show"
    get "/health", to: "health#check"
  end
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Suppress Chrome DevTools routing errors (reduce noise in logs)
  get "/.well-known/*path", to: proc { [ 204, {}, [] ] }

  # Defines the root path route ("/")
  # root "posts#index"
end
