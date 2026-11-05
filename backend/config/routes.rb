Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Active Storage 既定の direct upload を admin 認証付きコントローラで上書きする。
  # 同じパスをアプリ側で先に定義すると、engine 側の active_storage/direct_uploads#create
  # より先に照合される。名前付きルート rails_direct_uploads（フォームの
  # data-direct-upload-url）は engine 側のものがそのまま同じパスを生成する。
  post "#{ActiveStorage.routes_prefix}/direct_uploads" => 'admin/direct_uploads#create'

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
    resources :bucket_list_items do
      post :insert_at, on: :member
    end
  end
  # ジョブダッシュボード（認証は Admin::Base 経由、config/application.rb 参照）
  mount MissionControl::Jobs::Engine, at: "/admin/jobs"
  namespace :api do
    resources :images, only: %i[index]
    resources :categories, only: %i[index]
    resources :projects, only: %i[index]
    resources :bucket_list_items, only: %i[index] do
      resource :like, only: %i[create destroy], controller: 'bucket_list_likes'
    end
  end
end
