Rails.application.routes.draw do
  devise_for :users

  if ENV["CIRCULATE_SIGNUP"]
    namespace :signup do
      resources :members, only: [:new, :create]
      resources :documents, only: [:show] do
        resource :acceptance, only: [:create, :destroy]
      end
      resources :payments, only: [:new, :create]
      get "payments/callback", to: "payments#callback"
      get "confirmation", to: "confirmations#show"
      get "/", to: "home#index"
    end
  end

  namespace :admin do
    resources :documents, only: [:show, :edit, :update, :index]
    resources :borrow_policies
    resources :tags
    resources :items do
      get :number
    end
    resources :loans
    resources :members

    post "search", to: "searches#create"
    get "search", to: "searches#show"

    get "/ui/names", to: "ui#names"
    get "/ui/brands", to: "ui#brands"
    get "/ui/sizes", to: "ui#sizes"
    get "/ui/strengths", to: "ui#strengths"

    if Rails.env.development?
      post "/dev/time", to: "dev#set_time"
      delete "/dev/time", to: "dev#clear_time"
    end
  end
  root to: "home#index"
end
