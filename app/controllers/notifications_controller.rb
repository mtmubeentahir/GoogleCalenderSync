class NotificationsController < ApplicationController
  # This will be the endpoint Google sends notifications to
  def handle_google_calendar_notification
    resource_id = request.headers['X-Goog-Resource-ID']
    sync_token = request.headers['X-Goog-Sync-Token']

    Rails.logger.info("Received notification for resource_id: #{resource_id}, sync_token: #{sync_token}")

    # Fetch updated events and sync with the database
    calendar = Calendar.find_by(resource_id:)
    if calendar
      import_service = GoogleCalendarImportService.new(calendar.user.access_token)
      import_service.sync_events(calendar.google_id, sync_token)
    else
      Rails.logger.error("No calendar found for resource_id: #{resource_id}")
    end

    head :ok # Respond with 200 OK
  end
end
