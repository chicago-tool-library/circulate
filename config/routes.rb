Rails.application.routes.draw do
  resources :borrow_policies
  devise_for :users

  resources :categories
  resources :items do
    get :number
  end
  resources :loans
  resources :members

  get "/ui/names", to: "ui#names"
  get "/ui/brands", to: "ui#brands"

  if Rails.env.development?
    post "/dev/time", to: "dev#set_time"
    delete "/dev/time", to: "dev#clear_time"
  end

  root to: "home#index"
end