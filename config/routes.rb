Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "static#index"

  resources :time_off_requests do
    member do
      post :approve
      post :deny
    end
  end

  namespace :manager do
    resources :time_off_requests, only: [:index]
  end

  namespace :admin do
    resources :time_off_requests, only: [:index]
    resources :users
    resources :departments
  end

  namespace :api do
    namespace :v1 do
      resources :time_off_requests, only: [:index, :show, :create] do
        member do
          post :approve
          post :deny
        end
      end
    end
  end
end
