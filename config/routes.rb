Rails.application.routes.draw do
  get "projects/index"
  get "projects/show"
  get "projects/new"
  get "projects/create"
  get "projects/edit"
  get "projects/update"
  get "projects/destroy"
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "projects#index"

  # Projects and nested resources
  resources :projects do
    # Nested resources inside a project
    resources :acts, except: [:show] do
      member do
        patch :move # Drag & drop
      end
    end

    resources :sequences, except: [:show] do
      member do
        patch :move
      end
    end

    resources :scenes do
      member do
        patch :move
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

    # Special route for kanban
    get 'structure', to: 'structures#show', as: :structure
    post 'structure/reorder', to: 'structures#reorder', as: :reorder_structure
  end
end
