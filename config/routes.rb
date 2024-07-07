require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post :sign_up
        post :sign_in
        post :refresh_token
      end

      resources :folders, only: [:index, :create] do
        collection do
          put :rename
        end
      end

      resources :file_uploads, only: [:index, :create] do
        collection do
          get :view_file
          put :rename
        end
      end
    end

    match "*path", to: 'route_error#not_found', via: :all
  end
end
