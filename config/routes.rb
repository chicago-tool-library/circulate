Rails.application.routes.draw do
  devise_for :users, controllers: {sessions: "users/sessions"}

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

  namespace :account do
    resources :appointments, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :holds, only: [:index, :create, :destroy] do
      get :history, to: "holds#history", on: :collection
    end
    resources :loans, only: :index do
      get :history, to: "loans#history", on: :collection
    end
    resource :member, only: [:show, :edit, :update]
    resource :password, only: [:edit, :update]
    resources :renewals, only: :create
    resources :renewal_requests, only: :create
    get "/", to: "home#index", as: "home"
  end

  namespace :renewal do
    resource :member, only: [:edit, :update]
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

  namespace :volunteer do
    resources :shifts, only: [:index, :create, :destroy]
    resources :attendees, only: [:create, :destroy]
    get "event", to: "shifts#event"
    resource :session, only: [:destroy]
  end
  get "/auth/google_oauth2/callback", to: "volunteer/sessions#create"
  get "/auth/failure", to: "volunteer/sessions#failure"

  namespace :admin do
    resources :documents, only: [:show, :edit, :update, :index]
    resources :borrow_policies, only: [:index, :edit, :update]
    resources :categories, except: :show
    resources :gift_memberships
    resources :appointments, only: [:index, :show, :edit, :update, :destroy] do
      resources :holds, only: [:create, :destroy], controller: :appointment_holds
      resources :loans, only: [:create, :destroy], controller: :appointment_loans
      resources :checkouts, only: [:create], controller: :appointment_checkouts
      resources :checkins, only: [:create], controller: :appointment_checkins
      resource :completion, only: [:create, :destroy], controller: :appointment_completions
      resource :detail_completion, only: [:create, :destroy], controller: :appointment_detail_completions
    end
    resources :manage_features, only: [:index, :update]
    resources :items do
      scope module: "items" do
        resources :attachments
        resource :history, only: :show
        resource :loan_history, only: :show
        resources :holds, only: :index do
          scope module: "holds" do
            resource :position, only: :update
          end
        end
        resources :notes
        if ENV["FEATURE_MAINTENANCE_WORKFLOW"] == "on"
          resources :tickets do
            scope module: "tickets" do
              resources :ticket_updates, only: [:new, :create, :edit, :update, :destroy]
            end
          end
        end
      end

      get :number
      resource :image, only: [:edit, :update]
      resource :loan_history, only: :show
      # resource :manual_import, only: [:edit, :update]
    end
    resources :loan_summaries, only: :index
    resources :loans, only: [:index, :create, :update, :destroy]
    resources :renewals, only: [:create, :destroy]
    resources :bulk_renewals, only: [:update]

    resources :members do
      scope module: "members" do
        resources :holds, only: [:create, :index, :destroy] do
          post :lend, on: :member
          get :history, on: :collection
        end
        resource :hold_loan, only: :create
        resource :lookup, only: :show
        resources :memberships, only: [:index, :new, :create, :update]
        resources :payments, only: [:new, :create]
        resource :verification, only: [:edit, :update]
        resources :appointments, only: [:index, :create]
        resources :notifications, only: :index

        resources :loan_summaries, only: :index
        resources :notes
      end
    end

    namespace :reports do
      resources :memberships, only: :index
      resources :items_in_maintenance, only: :index
      resources :monthly_activities, only: :index
      resources :member_requests, only: :index
      resources :notifications, only: :index
      resources :potential_volunteers, only: :index
      resources :shifts, only: :index
      resources :items_without_image, only: :index
      resources :items_with_holds, only: :index
      resources :zipcodes, only: :index
      get "money", to: "money#index"
    end

    namespace :settings do
      get "closing", to: "closing#index"
      post "closing/extend_holds", to: "closing#extend_holds"
      resource :email_settings do
        get :preview, on: :member
      end
      resources :library_updates
      resources :exports, only: [:index] do
        post :items, on: :collection
        post :members, on: :collection
      end
    end

    resources :holds, only: [:index]
    resources :users
    resources :renewal_requests, only: [:index, :update]

    resource :map, only: :show

    post "search", to: "searches#create"
    get "search", to: "searches#show"

    get "/ui/names", to: "ui#names"
    get "/ui/brands", to: "ui#brands"
    get "/ui/sizes", to: "ui#sizes"
    get "/ui/strengths", to: "ui#strengths"

    if ENV["FEATURE_GROUP_LENDING"] == "on"
      # Group Lending
      resources :item_pools do
        scope module: "item_pools" do
          resource :availability, only: :show
          resources :reservable_items, except: :index
        end
      end
      resources :reservations do
        scope module: "reservations" do
          resource :review, only: [:edit, :update]
        end
      end
      resources :pickups do
        scope module: "pickups" do
          resources :reservation_loans, only: [:create, :destroy]
          resource :checkout, only: :create
          resource :checkin, only: :create
        end
      end
    end

    get "/", to: "dashboard#index", as: "dashboard"
  end

  if Rails.env.development?
    post "/dev/time", to: "dev#set_time"
    delete "/dev/time", to: "dev#clear_time"
  end

  get "/dev/styles", to: "dev#styles"

  get "/s/:id", to: "short_links#show", as: :short_link

  namespace :super_admin do
    resources :libraries
  end

  resources :items, only: [:index, :show]
  resources :documents, only: :show
  resources :homepage, only: [:index, :create]

  post "/twilio/callback", to: "twilio#callback"

  root to: "home#index"

  if Rails.env.test?
    get "/test/google_auth", to: "test#google_auth"
  end

  %w[404 422 500 503].each do |code|
    match code, to: "errors#show", via: :all, code: code, as: "error_#{code}"
  end
end
