Rails.application.routes.draw do
  devise_for :users

  scope :admin do
    resources :borrow_policies
    resources :categories
    resources :items do
      get :number
    end
    resources :loans
    resources :members
  end

  scope :register do
  end

  get "/ui/names", to: "ui#names"
  get "/ui/brands", to: "ui#brands"

  if Rails.env.development?
    post "/dev/time", to: "dev#set_time"
    delete "/dev/time", to: "dev#clear_time"
  end

  root to: "home#index"
end