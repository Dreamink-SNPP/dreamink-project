Rails.application.routes.draw do
  # Authentication (Rails 8)
  resource :session, only: [ :new, :create, :destroy ]
  resource :registration, only: [ :new, :create ]
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
      end
    end

    # Cambiar la ruta de structure para usar POST en reorder
    get "structure", to: "structures#show", as: :structure
    post "structure/reorder", to: "structures#reorder", as: :reorder_structure
  end
end
