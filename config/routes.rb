Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount Ckeditor::Engine => '/ckeditor'
  mount TryApi::Engine => '/developers'
  # mount ActionCable.server => '/cable'
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  namespace :api do
    namespace :v1 do
      resources :users, only: %i(index show create) do
        collection do
          post :forgot_password,
               :reset_password,
               :change_password,
               :change_email,
               :change_phone_number,
               :newsletter

          get :profile

          put :profile, action: :update
          delete :profile, action: :destroy
        end
      end

      resources :sessions, only: %i(create) do
        collection do
          delete :logout, action: :destroy
          post :social_login
        end
      end

      resources :pages, only: %i(show)do
        collection do
          get ':id/page', action: :html_page
        end
      end

      resources :categories, only: %i(show index)
      resources :reviews
      resources :products, only: %i(show index) do
        member do
          post :buy, :save
          delete :remove, :remove_purchase
        end

        collection do
          get :filters,
              :search_results,
              :suggestions,
              :shape_options
        end
      end

      resources :articles, only: %i(index show) do
        member do
          post :view
        end
      end

      resources :help, only: %i() do
        collection do
          get :answers
          post :contact
        end
      end

      resources :brands, only: :index
      resources :actions, only: :create
      resources :coupons, only: %i(index show)

      post :verify_recaptcha, to: 'recaptcha#verify'
      get :get_banner, to: 'ad_banners#get_banner'
      get :get_meta, to: 'meta_tags#get_meta'
    end
  end
end
