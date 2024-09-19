# spec/services/google_auth_service_spec.rb

require 'rails_helper'

RSpec.describe GoogleAuthService do
  let(:client_id) { 'test-client-id' }
  let(:client_secret) { 'test-client-secret' }
  let(:redirect_uri) { 'http://localhost:3000/callback' }
  let(:auth_service) { described_class.new(client_id, client_secret, redirect_uri) }

  before do
    allow(ENV).to receive(:[]).with('GOOGLE_CLIENT_ID').and_return(client_id)
    allow(ENV).to receive(:[]).with('GOOGLE_CLIENT_SECRET').and_return(client_secret)
    allow(ENV).to receive(:[]).with('GOOGLE_REDIRECT_URI').and_return(redirect_uri)
  end

  describe '#initialize' do
    context 'with valid credentials' do
      it 'does not raise an error' do
        expect { auth_service }.not_to raise_error
      end
    end

    context 'with missing credentials' do
      it 'raises an error for missing client_id' do
        expect {
          described_class.new(nil, client_secret, redirect_uri)
        }.to raise_error('Missing environment variables: GOOGLE_CLIENT_ID')
      end

      it 'raises an error for missing client_secret' do
        expect {
          described_class.new(client_id, nil, redirect_uri)
        }.to raise_error('Missing environment variables: GOOGLE_CLIENT_SECRET')
      end

      it 'raises an error for missing redirect_uri' do
        expect {
          described_class.new(client_id, client_secret, nil)
        }.to raise_error('Missing environment variables: GOOGLE_REDIRECT_URI')
      end
    end
  end

  describe '#get_authorization_url' do
    it 'generates the correct authorization URL' do
      authorization_url = auth_service.get_authorization_url

      uri = URI.parse(authorization_url)
      query_params = Rack::Utils.parse_query(uri.query)

      expect(query_params['client_id']).to eq(client_id)
      expect(query_params['redirect_uri']).to eq(redirect_uri)
      expect(query_params['response_type']).to eq('code')
      expect(query_params['scope']).to eq('https://www.googleapis.com/auth/calendar.readonly')
      expect(query_params['access_type']).to eq('offline')
      expect(query_params['prompt']).to eq('consent')
    end
  end

  describe '#request_token' do
    let(:code) { 'test-auth-code' }
    let(:refresh_token) { 'test-refresh-token' }
    let(:token_response) { { access_token: 'test-access-token', refresh_token: 'test-refresh-token' }.to_json }
    
    before do
      allow(HTTParty).to receive(:post).and_return(double(success?: true, body: token_response))
    end

    it 'exchanges authorization code for token' do
      expect(auth_service).to receive(:make_post_request).with('/token', hash_including(grant_type: 'authorization_code', code: code)).and_call_original
      result = auth_service.exchange_code_for_token(code)
      expect(result).to eq(JSON.parse(token_response))
    end

    it 'refreshes the access token' do
      expect(auth_service).to receive(:make_post_request).with('/token', hash_including(grant_type: 'refresh_token', refresh_token: refresh_token)).and_call_original
      result = auth_service.refresh_access_token(refresh_token)
      expect(result).to eq(JSON.parse(token_response))
    end
  end
end
