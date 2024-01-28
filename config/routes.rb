Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      post "/auth/sign_up", to: "auth#sign_up"
      post "/auth/sign_in", to: "auth#sign_in"

      resources :folders, only: [:create] do
        collection do
          post :rename, to: "folders#rename"
        end
      end

      match "*path", to: "route_error#not_found", via: :all
    end
  end
end
