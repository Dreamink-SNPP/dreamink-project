Rails.application.routes.draw do
  # Authentication (Rails 8)
  # Session routes
  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # Registration routes
  get "/register", to: "registrations#new", as: :register
  post "/register", to: "registrations#create"

  # Password reset routes
  get "/forgot-password", to: "passwords#new", as: :forgot_password
  post "/forgot-password", to: "passwords#create"
  get "/reset-password/:token", to: "passwords#edit", as: :reset_password
  patch "/reset-password/:token", to: "passwords#update"
  put "/reset-password/:token", to: "passwords#update"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root
  root "projects#index"

  # Projects and nested resources
  resources :projects do
    member do
      get :report
      get :fountain_export
    end

    # Nested resources inside a project
    resources :acts, except: [ :show ] do
      member do
              patch :move_left
              patch :move_right
              get :edit_modal
      end
      get "sequences/new_modal", to: "sequences#new_modal", as: :new_sequence_modal
    end

    resources :sequences, except: [ :show ] do
      member do
        get :edit_modal
        patch :move_to_act
        patch :move_left
        patch :move_right
      end
      get "scenes/new_modal", to: "scenes#new_modal", as: :new_scene_modal
    end

    resources :scenes do
      member do
        get :new_modal
        get :edit_modal
        patch :move_to_sequence
      end
      collection do
        get :by_location # Filter scenes by locations
      end
    end

    resources :characters do
      collection do
        get :collection_report
      end
      member do
        get :report
      end
    end
    resources :locations do
      collection do
        get :collection_report
      end
      member do
        get :report
      end
    end
    resources :ideas do
      collection do
        get :search
        get :collection_report
      end
      member do
        get :report
      end
    end

    # Cambiar la ruta de structure para usar POST en reorder
    get "structure", to: "structures#show", as: :structure
    post "structure/reorder", to: "structures#reorder", as: :reorder_structure
  end
end
