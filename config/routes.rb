Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root 'home#index'

  get 'unauthorized', to: 'home#unauthorized'

  # for pwa
  get '/service-worker.js' => 'service_worker#service_worker'
  get '/manifest.json' => 'service_worker#manifest'

  #post 'test_turbo', to: 'home#test_turbo'

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Routes for users
  resources :users, only: [:show, :edit, :update, :destroy]
  # admin management of users
  namespace :admin do
    resources :users, only: [:index, :destroy]
  end

  # Routes for account creation
  get 'signup', to: 'users#new'
  post 'users', to: 'users#create'

  # Routes for user authentication
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'


  # routes for recipes
  resources :recipes
  get 'public/recipes', to: 'recipes#public', as: :public_recipes
  # routes for ingredients
  # ingredients search with spoonacular API
  get 'ingredients/search', to: 'ingredients#search_spoonacular_ingredients'
  # routes for comments
  resources :recipes do
    resources :comments, only: [:create, :destroy]
  end
end
