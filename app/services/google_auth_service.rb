# app/services/google_auth_service.rb
class GoogleAuthService
  include HTTParty
  BASE_URL = 'https://oauth2.googleapis.com'
  BASE_URL = 'https://oauth2.googleapis.com'
  AUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth'

  def initialize(client_id = ENV['GOOGLE_CLIENT_ID'], client_secret = ENV['GOOGLE_CLIENT_SECRET'], redirect_uri = ENV['GOOGLE_REDIRECT_URI'])
    @client_id = client_id 
    @client_secret = client_secret 
    @redirect_uri = redirect_uri
    validate_credentials!
  end

  # Generate authorization URL to request user consent
  def get_authorization_url
    query_params = {
      client_id: @client_id,
      redirect_uri: @redirect_uri,
      response_type: 'code',
      scope: 'https://www.googleapis.com/auth/calendar.readonly',
      access_type: 'offline',
      prompt: 'consent'
    }
    "#{AUTH_URL}?#{query_params.to_query}"
  end

   # Exchange authorization code or refresh token for access token
   def request_token(grant_type:, code: nil, refresh_token: nil)
    body = {
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: @redirect_uri,
      grant_type: grant_type
    }
    body[:code] = code if grant_type == 'authorization_code'
    body[:refresh_token] = refresh_token if grant_type == 'refresh_token'

    response = make_post_request('/token', body)
    handle_response(response)
  end

  # Exchange authorization code for access token
  def exchange_code_for_token(code)
    request_token(grant_type: 'authorization_code', code: code)
  end

  # Refresh the access token using the refresh token
  def refresh_access_token(refresh_token)
    request_token(grant_type: 'refresh_token', refresh_token: refresh_token)
  end

  private

  # Validate that essential environment variables are set
  def validate_credentials!
    missing = []
    missing << 'GOOGLE_CLIENT_ID' unless @client_id
    missing << 'GOOGLE_CLIENT_SECRET' unless @client_secret
    missing << 'GOOGLE_REDIRECT_URI' unless @redirect_uri

    raise "Missing environment variables: #{missing.join(', ')}" if missing.any?
  end

  # Helper to make POST requests
  def make_post_request(endpoint, body)
    HTTParty.post("#{BASE_URL}#{endpoint}",
      body: body,
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    )
  end

  # Handle API response
  def handle_response(response)
    if response.success?
      JSON.parse(response.body)
    else
      Rails.logger.error("OAuth error: #{response.body}")
      nil
    end
  end
end
