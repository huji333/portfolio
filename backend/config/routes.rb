Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :admin do
    root to: 'index#index'
    resources :images do
      post :insert_at, on: :member
      collection do
        get :arrange
        post :extract_exif
      end
    end
    resource :image_bulk_import, only: %i[new create]
    resource :image_bulk_update, only: %i[update]
    get 'gear', to: 'gear#index'
    resources :cameras, except: %i[index show]
    resources :lenses, except: %i[index show]
    resources :categories
    resources :projects
  end
  # ジョブダッシュボード（認証は Admin::Base 経由、config/application.rb 参照）
  mount MissionControl::Jobs::Engine, at: "/admin/jobs"
  namespace :api do
    resources :images, only: %i[index]
    resources :categories, only: %i[index]
    resources :projects, only: %i[index]
  end
end
