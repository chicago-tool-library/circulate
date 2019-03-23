Rails.application.routes.draw do
  resources :categories
  resources :items
  resources :loans
  resources :members
end
