Rails.application.routes.draw do
  devise_for :users

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
    resources :redemptions, only: [:new, :create]

    get "confirmation", to: "confirmations#show"
    get "/", to: "home#index"
  end

  namespace :holds do
    resources :items, only: [:create, :destroy]
    resources :hold_requests, only: [:new, :create]
    resource :request, only: :destroy
    get "/", to: "home#index"
    get "autocomplete", to: "autocomplete#index"
    resources :confirmations, only: :show
  end

  get "member/history", to: "members#history", as: "member_loan_history"
  get "/member/loans", to: "members#loans", as: "member_loans"
  delete "/member/holds/:id", to: "members#delete_hold", as: "delete_member_hold"
  post "/member/loans/:id/renew", to: "members#renew", as: "member_loans_renew"

  namespace :volunteer do
    resources :shifts, only: [:index, :new, :create]
    resource :session, only: [:destroy]
  end
  get "/auth/google_oauth2/callback", to: "volunteer/sessions#create"

  namespace :admin do
    resources :documents, only: [:show, :edit, :update, :index]
    resources :borrow_policies, only: [:index, :edit, :update]
    resources :shifts, only: :index
    resources :categories, except: :show
    resources :hold_requests, only: :index
    resources :gift_memberships
    resources :items do
      get :number
      resource :image, only: [:edit, :update]
      resource :item_history, only: :show
      resource :loan_history, only: :show
      resource :manual_import, only: [:edit, :update]
      resources :item_holds, only: :index

      resources :notes
    end
    resources :loan_summaries, only: :index
    resources :loans, only: [:index, :create, :update, :destroy]
    resources :renewals, only: [:create, :destroy]

    resources :members, except: :destroy do
      scope module: "members" do
        resources :adjustments, only: :index
        resources :holds, only: [:create, :index, :destroy]
        resource :hold_loan, only: :create
        resources :lookups, only: :create
        resources :memberships, only: [:index, :new, :create]
        resources :payments, only: [:new, :create]
        resource :verification, only: [:edit, :update]

        resources :loan_summaries, only: :index
      end
    end

    resources :member_requests, only: :index
    resources :monthly_adjustments, only: :index
    resources :monthly_activities, only: :index
    resources :notifications, only: :index
    resources :potential_volunteers, only: :index
    resources :holds, only: [:index]
    resources :users

    post "search", to: "searches#create"
    get "search", to: "searches#show"

    get "/ui/names", to: "ui#names"
    get "/ui/brands", to: "ui#brands"
    get "/ui/sizes", to: "ui#sizes"
    get "/ui/strengths", to: "ui#strengths"

    if Rails.env.development?
      post "/dev/time", to: "dev#set_time"
      delete "/dev/time", to: "dev#clear_time"
      get "/dev/styles", to: "dev#styles"
    end

    get "/", to: "dashboard#index", as: "dashboard"
  end

  get "/s/:id", to: "short_links#show", as: :short_link

  resource :member_profile, only: [:show, :edit, :update]
  namespace :member_profiles do
    resource :password, only: [:edit, :update]
  end

  resources :items, only: [:index, :show]
  resources :documents, only: :show
  get "search", to: "searches#show"

  root to: "home#index"
end
