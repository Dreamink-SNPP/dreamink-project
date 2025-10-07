Rails.application.routes.draw do
  # Authentication (Rails 8)
  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, param: :token, only: [ :new, :create, :edit, :update ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root
  root "projects#index"

  # Projects and nested resources
  resources :projects do
    # Nested resources inside a project
    resources :acts, except: [ :show ] do
      member do
        patch :move # Drag & drop
      end
    end

    resources :sequences, except: [ :show ] do
      member do
        patch :move
        get :new_modal
      end
    end

    resources :scenes do
      member do
        patch :move
        get :new_modal
      end
      collection do
        get :by_location # Filter scenes by locations
      end
    end

    resources :characters
    resources :locations
    resources :ideas do
      collection do
        get :search
      end
    end

    # Special route for kanban board
    get 'structure', to: 'structures#show', as: :structure
    post 'structure/reorder', to: 'structures#reorder', as: :reorder_structure
  end
end
