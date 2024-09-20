require 'rails_helper'

RSpec.describe GoogleAuthController, type: :controller do
  describe 'GET #redirect' do
    it 'redirects to Google authorization URL' do
      oauth_service = instance_double(GoogleAuthService)
      allow(oauth_service).to receive(:get_authorization_url).and_return('http://mockauthurl.com')

      allow(GoogleAuthService).to receive(:new).and_return(oauth_service)

      get :redirect

      expect(response).to redirect_to('http://mockauthurl.com')
    end
  end

  describe 'GET #callback' do
    context 'when authorization code is provided' do
      before do
        @auth_service = instance_double(GoogleAuthService)
        @import_service = instance_double(GoogleCalendarImportService)

        allow(GoogleAuthService).to receive(:new).and_return(@auth_service)
        allow(@auth_service).to receive(:exchange_code_for_token).and_return({
                                                                               'access_token' => 'mock_access_token',
                                                                               'refresh_token' => 'mock_refresh_token'
                                                                             })
        allow(GoogleCalendarImportService).to receive(:new).with('mock_access_token').and_return(@import_service)
        allow(@import_service).to receive(:import_calendars_and_events)
      end

      it 'sets session tokens and redirects to calendars_path' do
        get :callback, params: { code: 'mock_authorization_code' }

        expect(session[:access_token]).to eq('mock_access_token')
        expect(session[:refresh_token]).to eq('mock_refresh_token')
        expect(response).to redirect_to(calendars_path)
      end

      it 'calls import_calendars_and_events on GoogleCalendarImportService' do
        get :callback, params: { code: 'mock_authorization_code' }

        expect(@import_service).to have_received(:import_calendars_and_events)
      end
    end

    context 'when authorization code is not provided' do
      it 'renders plain text with error message' do
        get :callback

        expect(response.body).to eq('Authorization code not received')
        expect(response.status).to eq(422)
      end
    end

    context 'when exchange_code_for_token fails' do
      before do
        @auth_service = instance_double(GoogleAuthService)
        allow(GoogleAuthService).to receive(:new).and_return(@auth_service)
        allow(@auth_service).to receive(:exchange_code_for_token).and_return(nil)
      end

      it 'renders plain text with error message' do
        get :callback, params: { code: 'mock_authorization_code' }

        expect(response.body).to eq('Failed to obtain access token')
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE #logout' do
    it 'clears session and redirects to root path with notice' do
      session[:access_token] = 'mock_access_token'

      delete :logout

      expect(session[:access_token]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('You have been logged out.')
    end
  end
end
