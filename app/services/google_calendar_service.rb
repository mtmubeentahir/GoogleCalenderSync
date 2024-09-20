class GoogleCalendarService
  include HTTParty
  BASE_URL = 'https://www.googleapis.com/calendar/v3'

  def initialize(access_token)
    @access_token = access_token
  end

  # Fetches the user's calendar list
  def calendar_list
    get_request('/users/me/calendarList')
  end

  # Fetches events for a specific calendar, with optional sync token
  def events(calendar_id, sync_token = nil)
    query_params = sync_token ? { syncToken: sync_token } : {}
    get_request("/calendars/#{calendar_id}/events", query_params)
  end

  # Create a channel to watch for changes in a calendar
  def watch_calendar(calendar_id, callback_url)
    url = "/calendars/#{calendar_id}/events/watch"
    body = {
      id: SecureRandom.uuid,   # Unique channel ID
      type: 'web_hook',        # Type of channel
      address: callback_url    # The callback URL to receive notifications
    }
    post_request(url, body)
  end

  private

  # Authorization headers for the requests
  def auth_headers
    {
      'Authorization' => "Bearer #{@access_token}",
      'Content-Type' => 'application/json'
    }
  end

  # General GET request handler
  def get_request(endpoint, query = {})
    response = HTTParty.get("#{BASE_URL}#{endpoint}", headers: auth_headers, query:)
    handle_response(response, endpoint)
  end

  # General POST request handler
  def post_request(endpoint, body)
    response = HTTParty.post("#{BASE_URL}#{endpoint}", headers: auth_headers, body: body.to_json)
    handle_response(response, endpoint)
  end

  # Handles the API response
  def handle_response(response, endpoint)
    if response.success?
      JSON.parse(response.body)
    else
      Rails.logger.error("Error with Google API (#{response.code}) on #{endpoint}: #{response.body}")
      nil
    end
  end
end
