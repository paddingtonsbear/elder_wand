require 'spec_helper'

describe ElderWand::Client do
  subject do
    ElderWand::Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
      builder.adapter :test do |stub|
        stub.post('/oauth/token') { |env| [200, {}, env[:body]] }
      end
    end
  end

  describe '#get_token_info' do
    it 'calls get_token with authorization and json header params' do
      token  = 'abcdef'
      params = {
        headers: {
          'Accept'        => 'application/json',
          'Content-Type'  => 'application/json',
          'Authorization' => "Bearer #{token}"
        }
      }
      expect(subject).to receive(:get_token).with(params)
      subject.get_token_info(token)
    end

    it 'uses the appropriate :token_method and :token_url' do
      expect(subject).to receive(:get_token)
      subject.get_token_info('abcdef')

      expect(subject.options[:token_url]).to eq '/oauth/token/info'
      expect(subject.options[:token_method]).to eq :get
    end
  end

  describe '#token_from_auth_code' do
    it 'uses the auth code strategy' do
      expect(subject.auth_code).to receive(:get_token)
      subject.token_from_auth_code('authorization_code')
    end

    it 'passes the authorization, accept and content_type header params' do
      code   = 'auth code'
      params = {
        headers: {
          'Accept'        => 'application/json',
          'Content-Type'  => 'application/json',
        },
        scopes: ['something'],
        resource_owner_id: 1
      }
      expect(subject.auth_code).to receive(:get_token).with(code, params)
      subject.token_from_auth_code(code, params)
    end
  end
end
