Rails.application.routes.draw do

  root "static_pages#home"

  get "/home", to: "static_pages#home"

  get "/help", to: "static_pages#help"

  get "/about", to: "static_pages#about"

  get "/contact", to: "static_pages#contact"

  get "/signup", to: "users#new"

  post "/signup", to: "users#create"

  get "/lang", to: "application#change_language"

  get "/login", to: "sessions#new"

  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy"

  resources :account_activations, only: %i(edit)
  resources :microposts, only: %i(create destroy)
  resources :password_resets, only: %i(new create edit update)
  resources :relationships, only: %i(create destroy)
  resources :users do
    member do
      get :following, :followers
    end
  end
end
