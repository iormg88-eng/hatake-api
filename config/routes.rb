Rails.application.routes.draw do
  # Register Devise's Warden scope for the User model without creating any routes
  devise_for :users, skip: :all

  namespace :api do
    namespace :v1 do
      post   "users/sign_up",  to: "registrations#create"
      post   "users/sign_in",  to: "sessions#create"
      delete "users/sign_out", to: "sessions#destroy"

      get "me", to: "users#me"

      resources :groups, only: [ :create, :show ] do
        member do
          post :join
        end
        resources :fields, only: [ :index, :create, :update, :destroy ]
      end

      resources :field_logs, only: [ :index, :create ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
