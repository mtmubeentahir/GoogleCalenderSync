class GoogleAuthController < ApplicationController
  def redirect
    oauth_service = GoogleAuthService.new
    @auth_url = oauth_service.get_authorization_url

    redirect_to @auth_url, allow_other_host: true
  end

  # Callback handler once Google authenticates the user
  def callback
    oauth_service = GoogleAuthService.new

    if params[:code]
      tokens = oauth_service.exchange_code_for_token(params[:code])

      if tokens
        session[:access_token] = tokens['access_token']
        session[:refresh_token] = tokens['refresh_token']

        import_service = GoogleCalendarImportService.new(session[:access_token])
        import_service.import_calendars_and_events

        redirect_to calendars_path
      else
        render plain: 'Failed to obtain access token', status: :unprocessable_entity
      end
    else
      render plain: 'Authorization code not received', status: :unprocessable_entity
    end
  end

  def logout
    session.delete(:access_token)
    redirect_to root_path, notice: 'You have been logged out.'
  end
end
