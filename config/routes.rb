Rails.application.routes.draw do
  devise_for :users
  resources :categories
  resources :items do
    get :number
  end
  resources :loans
  resources :members

  root to: "items#index"
end