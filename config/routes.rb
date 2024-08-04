require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'

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
          delete :remove_folder
        end
      end

      resources :file_uploads, only: [:index, :create] do
        collection do
          get :view_file
          put :rename
          delete :remove_file
        end
      end
    end

    match "*path", to: 'route_error#not_found', via: :all
  end
end
