Rails.application.routes.draw do

  root 'static#index'

  # Static Landing, FAQ Pages
  get '/stories'        => 'static#stories',        as: :stories
  get '/questions'      => 'static#questions',      as: :questions
  get '/hosting'        => 'static#hosting',        as: :hosting
  get '/about'          => 'static#about',          as: :about
  get '/internproject'  => 'static#internproject',  as: :internproject
  get '/birthdays'      => 'static#birthdays',      as: :birthdays
  get '/openhouse'      => 'static#openhouse',      as: :openhouse

  devise_for :users, :controllers => {:registrations => "registrations"}, :skip => [:sessions]

  devise_for :users, :controllers => {
    :registrations => "registrations",
    :confirmations => "confirmations"
  }, :skip => [:sessions]

  as :user do
    get 'signin' => 'devise/sessions#new', :as => :new_user_session
    post 'signin' => 'devise/sessions#create', :as => :user_session
    delete 'signout' => 'devise/sessions#destroy', :as => :destroy_user_session
    get 'logout' => 'devise/sessions#destroy'
    patch '/user/confirmation' => 'confirmations#update', :via => :patch, :as => :update_user_confirmation
  end

  resources :tea_times do
    member do
      post '/attendance'                => 'tea_times#create_attendance', as: :attendance
      patch '/attendance/all'           => 'attendance#mark',             as: :mark
      put '/cancel'                     => 'tea_times#cancel',            as: :cancel
      get '/attendance/:attendance_id'  => 'attendance#show',             as: :show_attendance
      put '/attendance/:attendance_id'  => 'attendance#update',           as: :update_attendance
    end
  end

  resources :cities do
    member do
      get '/host/:host_id' => 'hosts#show', as: :host
      get '/schedule', action: 'schedule',  as: :schedule
    end
  end

  # Fix Ankit's Typo Apr 22 2015
  get '/citiles/:city', to: redirect('/cities/%{city}')

  scope(path: 'admin')  do
    get '/ghost'          => 'admin#find'
    post '/ghost'         => 'admin#ghost'
    get '/overview'       => 'admin#overview'
    get '/overview/hosts' => 'admin#host_overview'
    get '/users'          => 'admin#users'
    get '/mail'           => 'admin#write_mail'
    post '/mail'          => 'admin#send_mail'
  end

  get '/host/new' => 'hosts#new', as: :new_host
  post '/host' => 'hosts#create', as: :create_host

  scope(path: 'profile') do
    match ''        => 'profiles#show',       as: :profile, via: :get
    get '/history'  => 'profiles#history',    as: :history
    get '/tasks'    => 'profiles#host_tasks', as: :host_tasks
  end
end
