require 'spec_helper'

describe ElderWand::Client do
  let(:app_info_url)   { '/oauth/application/info' }
  let(:token_url)      { '/oauth/token' }
  let(:revoke_url)     { '/oauth/revoke' }
  let(:token_info_url) { '/oauth/token/info' }
  let(:client_id)      { 'abc' }
  let(:client_secret)  { 'def' }
  let(:provider_url)   { 'https://api.example.com' }

  def elder_wand_client(opts = {})
    ElderWand::Client.new(client_id, client_secret, site: provider_url) do |builder|
      builder.adapter :test do |stub|
        stub.post(opts[:url]) do |env|
          [ opts[:status], { 'Content-Type' => 'application/json' }, opts[:body] ]
        end
        stub.get(opts[:url]) do |env|
          [ opts[:status], { 'Content-Type' => 'application/json' }, opts[:body] ]
        end
      end
    end
  end

  describe '#get_token' do
    context 'request successful' do
      let(:expected_params) do
        {
          headers: {
            'Accept'        => 'application/json',
            'Content-Type'  => 'application/x-www-form-urlencoded',
            'Authorization' => 'code'
          },
          body: {
            scope: 'something',
            resource_owner_id: 1
          },
          raise_errors: false
        }
      end
      let(:params) do
        {
          headers: { 'Authorization' => 'code' },
          scope: 'something',
          resource_owner_id: 1
        }
      end

      subject do
        elder_wand_client(
          url: token_url,
          status: 201,
          body: MultiJson.encode(
                  scope:            'swim dance',
                  revoked:           false,
                  expired:           false,
                  expires_in:        20,
                  access_token:      'some token',
                  refresh_token:     'refresh token',
                  resource_owner_id: 1
                )
        )
      end

      it 'makes a request with the appropriate params and headers' do
        expect(subject).to receive(:request)
          .with(:post, subject.token_url, expected_params)
          .and_call_original
        subject.get_token(params)
      end

      it 'initializes an AccessToken' do
        token = subject.get_token(params)
        expect(token).to be_a ElderWand::AccessToken
      end
    end

    context 'request fails' do
      subject do
        elder_wand_client(
          url: token_url,
          status: 401,
          body: MultiJson.encode(
                  meta: {
                    code: 401,
                    error_type: 'invalid'
                  },
                  reasons: ['some errors']
                )
        )
      end

      it 'raises an error' do
        expect { subject.get_token({}) }.to raise_error(ElderWand::Errors::RequestError)
      end
    end

    context 'response does not include access token' do
      subject do
        elder_wand_client(
          url: token_url,
          status: 201,
          body: MultiJson.encode(
                  scope:            'swim dance',
                  revoked:           false,
                  expired:           false,
                  expires_in:        20,
                  refresh_token:     'refresh token',
                  resource_owner_id: 1
                )
        )
      end

      it 'raises an error' do
        expect { subject.get_token({}) }.to raise_error(ElderWand::Errors::RequestError)
      end
    end
  end

  describe '#get_token_info' do
    let(:token) { 'abcdef' }
    let(:params) do
      {
        headers: {
          'Authorization' => "Bearer #{token}"
        }
      }
    end

    context 'request successful' do
      subject do
        elder_wand_client(
          url: token_info_url,
          status: 201,
          body: MultiJson.encode(
                  scope:            'swim dance',
                  revoked:           false,
                  expired:           false,
                  expires_in:        20,
                  access_token:      'some token',
                  refresh_token:     'refresh token',
                  resource_owner_id: 1
                )
        )
      end

      it 'calls #get_token with authorization and json header params' do
        expect(subject).to receive(:get_token).with(params)
        subject.get_token_info(token)
      end

      it 'uses the appropriate :token_method and :token_url' do
        expect(subject).to receive(:get_token)
        subject.get_token_info(token)

        expect(subject.options[:token_url]).to eq token_info_url
        expect(subject.options[:token_method]).to eq :get
      end

      it 'initializes an AccessToken if request is successful' do
        token = subject.get_token_info(token)
        expect(token).to be_a ElderWand::AccessToken
      end
    end

    context 'request fails' do
      subject do
        elder_wand_client(
          url: token_info_url,
          status: 401,
          body: MultiJson.encode(
                  meta: {
                    code: 401,
                    error_type: 'invalid'
                  },
                  reasons: ['some errors']
                )
        )
      end

      it 'raises an error' do
        expect { subject.get_token_info(token) }.to raise_error(ElderWand::Errors::RequestError)
      end
    end
  end

  describe '#token_from_auth_code' do
    let(:code) { 'auth code' }
    let(:params) do
      {
        headers: {
          'Accept'        => 'application/json',
          'Content-Type'  => 'application/json',
        },
        scope: 'something',
        resource_owner_id: 1
      }
    end

    context 'request successful' do
      subject do
        elder_wand_client(
          url: token_url,
          status: 201,
          body: MultiJson.encode(
                  scope:            'swim dance',
                  revoked:           false,
                  expired:           false,
                  expires_in:        20,
                  access_token:      'some token',
                  refresh_token:     'refresh token',
                  resource_owner_id: 1
                )
        )
      end

      it 'uses the auth code strategy' do
        expect(subject.auth_code).to receive(:get_token)
        subject.token_from_auth_code('authorization_code')
      end

      it 'makes a request with the appropriate params' do
        expect(subject.auth_code).to receive(:get_token).with(code, params)
        subject.token_from_auth_code(code, params)
      end

      it 'initializes an AccessToken' do
        token = subject.token_from_auth_code(code, params)
        expect(token).to be_a ElderWand::AccessToken
      end
    end

    context 'request fails' do
      subject do
        elder_wand_client(
          url: token_url,
          status: 401,
          body: MultiJson.encode(
                  meta: {
                    code: 401,
                    error_type: 'invalid'
                  },
                  reasons: ['some errors']
                )
        )
      end

      it 'raises an error' do
        expect { subject.token_from_auth_code(code, params) }.to raise_error(ElderWand::Errors::RequestError)
      end
    end
  end

  describe '#token_from_password_strategy' do
    let(:params) do
      {
        scope: ['something'],
        resource_owner_id: 1
      }
    end
    let(:expected_params) do
      {
        scope:             ['something'],
        grant_type:        'password',
        client_id:         client_id,
        client_secret:     client_secret,
        resource_owner_id: 1,
      }
    end

    context 'request successful' do
      subject do
        elder_wand_client(
          url: token_url,
          status: 201,
          body: MultiJson.encode(
                  scope:            'swim dance',
                  revoked:           false,
                  expired:           false,
                  expires_in:        20,
                  access_token:      'some token',
                  refresh_token:     'refresh token',
                  resource_owner_id: 1
                )
        )
      end

      it 'makes a request with the appropriate params' do
        expect(subject).to receive(:get_token).with(expected_params)
        subject.token_from_password_strategy(params)
      end

      it 'initializes an AccessToken' do
        token = subject.token_from_password_strategy(params)
        expect(token).to be_a ElderWand::AccessToken
      end
    end

    context 'request fails' do
      subject do
        elder_wand_client(
          url: token_url,
          status: 401,
          body: MultiJson.encode(
                  meta: {
                    code: 401,
                    error_type: 'invalid'
                  },
                  reasons: ['some errors']
                )
        )
      end

      it 'raises an error' do
        expect { subject.token_from_password_strategy(params) }.to raise_error(ElderWand::Errors::RequestError)
      end
    end
  end

  describe '#get_client_application_info' do
    context 'request successful' do
      subject do
        elder_wand_client(
          url: app_info_url,
          status: 200,
          body: MultiJson.encode(
                  uid: 'some uid',
                  name: 'some client app name',
                  secret: 'some client app secret',
                  scope: 'swim dance'
                )
        )
      end

      it 'makes a request with the appropriate params' do
        params = {
          headers: {
            'Accept'        => 'application/json',
            'Content-Type'  => 'application/json',
          },
          params: {
            client_id: client_id,
            client_secret: client_secret
          },
          raise_errors: false
        }
        expect(subject).to receive(:request).
          with(:get, app_info_url, params).
          and_call_original
        subject.get_client_application_info
      end

      it 'initializes a ClientApplication' do
        app = subject.get_client_application_info
        expect(app).to be_a ClientApplication
      end
    end

    context 'request fails' do
      subject do
        elder_wand_client(
          url: app_info_url,
          status: 401,
          body:   MultiJson.encode(
                    meta: {
                      code: 401,
                      error_type: 'invalid'
                    },
                    reasons: ['some errors']
                  )
        )
      end

      it 'raises an error' do
        expect { subject.get_client_application_info }.to raise_error(ElderWand::Errors::RequestError)
      end
    end
  end

  describe '#revoke_token' do
    let(:token) { 'abcdef' }

    context 'request successful' do
      subject do
        elder_wand_client(
          url: revoke_url,
          status: 200,
          body: {}
        )
      end

      it 'returns true' do
        expect(subject.revoke_token(token)).to be true
      end
    end

    context 'request fails' do
      subject do
        elder_wand_client(
          url: revoke_url,
          status: 401,
          body: {}
        )
      end

      it 'returns false' do
        expect(subject.revoke_token(token)).to be false
      end
    end
  end
end
