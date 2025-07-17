# require "sidekiq/web"
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # authenticate :user, lambda { current_user.is_a?(Admin) } do
  #   mount Sidekiq::Web  => "/sidekiq"
  # 
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  },  controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  namespace :api do
    namespace :v1 do
      get "analytics/most_purchased_products_by_category", to: "analytics#most_purchased_products_by_category"
      get "analytics/top_revenue_products_by_category", to: "analytics#top_revenue_products_by_category"
      get "analytics/purchases_list", to: "analytics#purchases_list"
      get "analytics/purchase_counts_by_granularity", to: "analytics#purchase_counts_by_granularity"

      resources :categories
      resources :customers
      resources :products

      namespace :user do
        get "current_user", to: "current_user#index"
      end

      namespace :audits do
        get "admin_changes", to: "admin_changes#index"
      end
    end
  end
end
