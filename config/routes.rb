Rails.application.routes.draw do
  devise_for :users

  if ENV["CIRCULATE_SIGNUP"]
    namespace :signup do
      resources :members, only: [:new, :create]
      scope :documents do
        get :agreement, to: "documents#agreement"
        get :rules, to: "documents#rules"

        resource :acceptance, only: [:create, :destroy]
      end
      resources :payments, only: [:new, :create] do
        get :callback, on: :collection
        post :skip, on: :collection
      end
      get "confirmation", to: "confirmations#show"
      get "/", to: "home#index"
    end
  end

  namespace :admin do
    resources :documents, only: [:show, :edit, :update, :index]
    resources :borrow_policies, only: [:index, :edit, :update]
    resources :tags
    resources :items do
      get :number
      resource :image, only: [:show, :update]
      resource :loan_history, only: :show
    end
    resources :loans do
      resources :renewals, only: :create
    end
    resources :members, except: :destroy do
      resource :loan_history, only: :show
      resource :activation, only: [:edit, :update]
      resources :memberships, only: [:index, :new, :create]
    end
    resources :member_requests, only: :index

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

  resources :items, only: [:index, :show]

  root to: "home#index"
end
