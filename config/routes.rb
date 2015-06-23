Rails.application.routes.draw do
  root 'static#index'
  get '/about'          => 'static#about',          as: :about
  get '/hosting'        => 'static#hosting',        as: :hosting
  get '/signup'         => 'static#jfdi_signup',    as: :sign_up

  # Devise and Registration Routes
  devise_for :users, :controllers => {:registrations => "registrations"}, :skip => [:sessions]
  as :user do
    get     'signin'   => 'sessions#new',             as: :new_user_session
    post    'signin'   => 'sessions#create',          as: :user_session
    delete  'signout'  => 'sessions#destroy',         as: :destroy_user_session
    get     'logout'   => 'sessions#destroy'
  end

  namespace :api do
    namespace :v1 do
      resources :cities,  only: [:index, :create]
      resources :hosts,   only: [:index]
      resources :users do
        collection do
          get 'self', to: :self
          get 'self/interests',   to: :interests
          patch 'self/interests', to: :update_interests
        end
      end

    end
  end

  resources :tea_times do
    member do
      post '/attendance'                => 'attendance#create', as: :attendance
      patch '/attendance/all'           => 'attendance#mark',             as: :mark
      put '/cancel'                     => 'tea_times#cancel',            as: :cancel
      get '/attendance/:attendance_id'  => 'attendance#show',             as: :show_attendance
      put '/attendance/:attendance_id'  => 'attendance#update',           as: :update_attendance
      put '/attendance/:attendance_id/cancel'  => 'attendance#cancel',    as: :cancel_attendance
    end
  end

  resources :cities do
    collection do
      get '/suggest'  => 'city_suggestions#new',     as: :suggest
      post '/suggest' => 'city_suggestions#create',  as: :suggest_create
    end
    member do
      get '/host/:host_id' => 'hosts#show',   as: :host
      put '/set', action: 'forbes_set_city',  as: :set
    end
  end

  scope :admin  do
    get '/ghost'              => 'admin#find'
    post '/ghost'             => 'admin#ghost'
    get '/overview'           => 'admin#overview'
    get '/overview/tea_times' => 'admin#tea_times_overview'
    get '/overview/cities'    => 'admin#cities_overview'
    get '/overview/hosts'     => 'admin#host_overview'
    get '/users'              => 'admin#users'
    get '/mail'               => 'admin#write_mail'
    post '/mail'              => 'admin#send_mail'
    get '/host'               => 'hosts#new',                 as: :new_host
    post '/host'              => 'hosts#create',              as: :create_host
  end

  scope :profile do
    get '/'                 => 'profiles#show',       as: :profile, via: :get
    get '/history'          => 'profiles#history',    as: :history
    get '/tasks'            => 'profiles#host_tasks', as: :host_tasks
    get '/host_dashboard'   => 'profiles#host_dashboard', as: :host_dashboard
  end

  get '/:id' => 'cities#show', as: :forbes_city
end
