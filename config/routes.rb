Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'calendars#index' # Root path to display calendars and events

  # Google OAuth routes
  get '/auth/google', to: 'google_auth#redirect', as: 'google_login'
  get '/oauth2callback', to: 'google_auth#callback'

  # Calendar routes
  resources :calendars, only: [:index]

  # Logout path if you want to handle session clearing
  delete '/logout', to: 'google_auth#logout', as: 'logout'

  # config/routes.rb
  post '/notifications/google_calendar', to: 'notifications#handle_google_calendar_notification',
                                         as: 'google_calendar_notification'
end
