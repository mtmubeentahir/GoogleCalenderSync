class GoogleCalendarImportService
  def initialize(access_token, sync_token = nil)
    @google_service = GoogleCalendarService.new(access_token)
    @sync_token = sync_token
  end

  def import_calendars_and_events
    calendar_list = @google_service.calendar_list
    return Rails.logger.error("Failed to fetch calendar list") if calendar_list.nil?

    ActiveRecord::Base.transaction do
      calendar_list['items'].each do |calendar_item|
        calendar = create_or_update_calendar(calendar_item)
        import_events(calendar)
        watch_calendar_for_updates(calendar)
      end
    end
  end

  private

  # Creates or updates a calendar in the database
  def create_or_update_calendar(calendar_item)
    Calendar.find_or_create_by(google_id: calendar_item['id']) do |calendar|
      calendar.name = calendar_item['summary']
      calendar.description = calendar_item['description']
      calendar.time_zone = calendar_item['timeZone']
    end
  end

  # Imports events for a specific calendar
  def import_events(calendar)
    events = @google_service.events(calendar.google_id, @sync_token)
    return Rails.logger.error("Failed to fetch events for calendar: #{calendar.google_id}") if events.nil?

    events['items'].each do |event_item|
      create_or_update_event(event_item, calendar)
    end
  end

  # Creates or updates an event in the database
  def create_or_update_event(event_item, calendar)
    Event.find_or_create_by(google_id: event_item['id'], calendar: calendar) do |event|
      event.summary     = event_item['summary']
      event.description = event_item['description']
      event.start_time  = event_item.dig('start', 'dateTime') || event_item.dig('start', 'date')
      event.end_time    = event_item.dig('end', 'dateTime') || event_item.dig('end', 'date')
      event.location    = event_item['location']
      event.status      = event_item['status']
    end
  end

  # Sets up a webhook to watch for updates to a calendar
  def watch_calendar_for_updates(calendar)
    callback_url = google_calendar_notification_url
    @google_service.watch_calendar(calendar.google_id, callback_url)
  rescue StandardError => e
    Rails.logger.error("Failed to watch calendar updates for #{calendar.google_id}: #{e.message}")
  end
end
