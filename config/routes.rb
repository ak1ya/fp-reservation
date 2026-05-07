Rails.application.routes.draw do
  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check

  get    "login",  to: "sessions#new",     as: :login
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get  "register", to: "registrations#new",    as: :register
  post "register", to: "registrations#create"

  resources :fps, only: [:index, :show]

  namespace :fp do
    get  "slots",  to: "available_slots#index",  as: :available_slots
    post "slots",  to: "available_slots#create"
  end

  resources :reservations, only: [:index, :create, :destroy]
end
