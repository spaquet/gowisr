Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "welcome#index"

  # Authentication routes
  scope :auth, controller: :auth do
    get "login", action: :login, as: :auth_login
    get "register", action: :register, as: :auth_register
    post "magic_link", action: :magic_link, as: :auth_magic_link
    get "link_sent", action: :link_sent, as: :auth_link_sent
    get "callback", action: :callback, as: :auth_callback
    delete "logout", action: :logout, as: :auth_logout
  end

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # User profile and settings
  get "profile", to: "users#profile", as: :profile
  get "settings", to: "users#settings", as: :settings

  # Frequently used static pages
  get "pricing", to: "pages#pricing", as: :pricing
  get "features", to: "pages#features", as: :features
  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact
  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms

  # PWA routes - commented out for now
  # get "/manifest.json", to: "pwa#manifest", as: :pwa_manifest
  # get "/offline", to: "pwa#offline", as: :pwa_offline

  # Catch all for static pages
  get ":page", to: "pages#show", as: :page, constraints: { page: /[a-z0-9-]+/ }

  # Chat and messages routes
  resources :chats do
    member do
      patch :toggle_favorite
      patch :toggle_thinking
    end

    resources :messages, only: [ :create, :destroy ]
  end
end
