require 'rails_helper'

RSpec.describe CalendarsController, type: :controller do
  describe 'GET #index' do
    context 'when there is an access token in the session' do
      before do
        session[:access_token] = 'mock_access_token'
        
        @calendar = Calendar.create!(google_id: 'mock_google_id')
        @event = @calendar.events.create!(google_id: 'mock_event_id', summary: 'Test Event', start_time: Time.now, end_time: Time.now + 1.hour)
      end

      it 'assigns @calendars with calendars and their events' do
        get :index

        expect(assigns(:calendars)).to eq([@calendar])
        expect(assigns(:calendars).first.events).to include(@event)
      end

      it 'renders the index template' do
        get :index

        expect(response).to render_template(:index)
      end
    end

    context 'when there is no access token in the session' do
      before do
        session[:access_token] = nil
      end

      it 'assigns @calendars as an empty array' do
        get :index

        expect(assigns(:calendars)).to eq([])
      end

      it 'renders the index template' do
        get :index

        expect(response).to render_template(:index)
      end
    end
  end
end
