# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :admin do
    root to: 'index#index'
    resources :images do
      member do
        post :insert_at
      end
    end
    resources :cameras do
      collection do
        get :lookup
      end
    end
    resources :lenses do
      collection do
        get :lookup
      end
    end
    resources :categories
    resources :projects
  end
  namespace :api do
    resources :images, only: %i[index]
    resources :categories, only: %i[index]
    resources :projects, only: %i[index]
    post :camera_name, to: 'camera_names#create'
  end
end
# rubocop:enable Metrics/BlockLength
