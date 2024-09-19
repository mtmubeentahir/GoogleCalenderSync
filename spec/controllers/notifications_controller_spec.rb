require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:resource_id) { 'mock_resource_id' }
  let(:sync_token) { 'mock_sync_token' }
  let(:access_token) { 'mock_access_token' }
  let(:google_id) { 'mock_google_id' }
  let(:calendar) { double('Calendar', user: double('User', access_token: access_token), google_id: google_id) }

  before do
    request.headers['X-Goog-Resource-ID'] = resource_id
    request.headers['X-Goog-Sync-Token'] = sync_token
  end

  describe 'POST #handle_google_calendar_notification' do
    context 'when the calendar is found' do
      before do
        allow(Calendar).to receive(:find_by).with(resource_id: resource_id).and_return(calendar)
        allow(GoogleCalendarImportService).to receive_message_chain(:new, :sync_events)
      end

      it 'calls the GoogleCalendarImportService to sync events' do
        expect(GoogleCalendarImportService).to receive_message_chain(:new, :sync_events).with(google_id, sync_token)

        post :handle_google_calendar_notification
      end

      it 'responds with 200 OK' do
        post :handle_google_calendar_notification
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the calendar is not found' do
      before do
        allow(Calendar).to receive(:find_by).with(resource_id: resource_id).and_return(nil)
        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error' do
        expect(Rails.logger).to receive(:error).with("No calendar found for resource_id: #{resource_id}")

        post :handle_google_calendar_notification
      end

      it 'responds with 200 OK' do
        post :handle_google_calendar_notification
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
