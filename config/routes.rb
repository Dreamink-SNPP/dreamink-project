Rails.application.routes.draw do
  get "ideas/index"
  get "ideas/new"
  get "ideas/create"
  get "ideas/edit"
  get "ideas/update"
  get "ideas/destroy"
  get "ideas/search"
  get "locations/index"
  get "locations/show"
  get "locations/new"
  get "locations/create"
  get "locations/edit"
  get "locations/update"
  get "locations/destroy"
  get "characters/index"
  get "characters/show"
  get "characters/new"
  get "characters/create"
  get "characters/edit"
  get "characters/update"
  get "characters/destroy"
  get "scenes/index"
  get "scenes/show"
  get "scenes/new"
  get "scenes/create"
  get "scenes/edit"
  get "scenes/update"
  get "scenes/destroy"
  get "sequences/index"
  get "sequences/new"
  get "sequences/create"
  get "sequences/edit"
  get "sequences/update"
  get "sequences/destroy"
  get "acts/index"
  get "acts/new"
  get "acts/create"
  get "acts/edit"
  get "acts/update"
  get "acts/destroy"
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
