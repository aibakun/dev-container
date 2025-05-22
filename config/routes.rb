Rails.application.routes.draw do
  namespace :api do
    resources :users, only: [:index]
    resources :orders, only: [:create]
    resources :order_statistics, only: [:index]
    resources :shipments, only: [:update]
    resources :inventories, only: %i[show update]
  end

  root 'users#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'up' => 'rails/health#show', as: :rails_health_check

  resource :request_logs, only: [:show]
  resource :activerecord_logs, only: [:show]
  resource :code_searches, only: [:show]

  resources :users do
    resources :posts
  end

  resources :tags
  resources :permissions
  resources :events

  resources :products do
    resources :product_sales_infos, only: %i[new create]
  end

  resources :product_sales_infos, only: %i[index edit update]

  resources :purchase_histories

  resources :orders, only: %i[index show new create] do
    resources :order_cancels, only: %i[new create destroy]
  end
  resource :cart, only: [:show]
  resources :cart_items, only: %i[create update destroy]
  namespace :cart_items do
    resources :orders, only: [:create]
  end
end
