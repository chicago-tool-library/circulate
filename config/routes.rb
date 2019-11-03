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

  namespace :volunteer do
    resources :shifts, only: [:index, :new, :create]
    resource :session, only: [:destroy]
  end
  get "/auth/google_oauth2/callback", to: "volunteer/sessions#create"

  namespace :admin do
    resources :documents, only: [:show, :edit, :update, :index]
    resources :borrow_policies, only: [:index, :edit, :update]
    resources :shifts, only: :index
    resources :tags
    resources :items do
      get :number
      resource :image, only: [:edit, :update]
      resource :loan_history, only: :show
    end
    resources :loan_summaries, only: :index
    resources :loans do
      resources :renewals, only: :create
    end
    resources :members, except: :destroy do
      resource :loan_history, only: :show
      resource :activation, only: [:edit, :update]
      resources :memberships, only: [:index, :new, :create]
      resources :adjustments, only: :index
      resources :payments, only: [:new, :create]
    end
    resources :member_requests, only: :index
    resources :monthly_adjustments, only: :index
    resources :monthly_activities, only: :index
    resources :notifications, only: :index
    resources :potential_volunteers, only: :index

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

    get "/", to: redirect("/admin/items")
  end

  resources :items, only: [:index, :show]
  get "search", to: "searches#show"

  root to: "home#index"
end
