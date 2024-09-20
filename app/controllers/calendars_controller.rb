# app/controllers/calendars_controller.rb
class CalendarsController < ApplicationController
  def index
    @calendars = if session[:access_token]
                   Calendar.includes(:events)
                 else
                   []
                 end
  end

  private

  # Redirect to Google login if no access token is found
  def require_google_auth
    return if session[:access_token]

    redirect_to google_login_path
  end
end
