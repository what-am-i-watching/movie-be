Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#show'

      resources :movies, only: [ :index, :show ] do
        collection do
          get :search
        end
      end
      devise_for :users,
        path: 'users',
        controllers: {
          sessions: 'api/v1/users/sessions',
          registrations: 'api/v1/users/registrations'
        },
        defaults: { format: :json }
      # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

      # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
      # Can be used by load balancers and uptime monitors to verify that the app is live.
      get "up" => "rails/health#show", as: :rails_health_check

      # Defines the root path route ("/")
      # root "posts#index"
    end
  end
end
