require 'spec_helper'

describe AccessToken do
  let(:token) { 'monkey' }
  let(:refresh_body) { MultiJson.encode(:access_token => 'refreshed_foo', :expires_in => 600, :refresh_token => 'refresh_bar') }
  let(:client) do
    Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
     builder.request :url_encoded
     builder.adapter :test do |stub|
       VERBS.each do |verb|
         stub.send(verb, '/token/header') { |env| [200, {}, env[:request_headers]['Authorization']] }
         stub.send(verb, "/token/query?access_token=#{token}") { |env| [200, {}, Addressable::URI.parse(env[:url]).query_values['access_token']] }
         stub.send(verb, '/token/body') { |env| [200, {}, env[:body]] }
       end
       stub.post('/oauth/token') { |env| [200, {'Content-Type' => 'application/json'}, refresh_body] }
     end
    end
  end

  subject { AccessToken.new(client, token) }

  describe '#initialize' do
    it 'assigns client and token' do
     expect(subject.client).to eq(client)
     expect(subject.token).to eq(token)
    end

    def assert_initialized_token(target)
     expect(target.token).to eq(token)
     expect(target).to be_expires
    end

    it 'initializes with a Hash' do
     hash = { :access_token => token }
     target = AccessToken.from_hash(client, hash)

     expect(target.token).to eq token
    end

    it 'initializes expires_in with params expires_in_seconds or expires_in' do
     hash = { :access_token => token, :expires_in_seconds => '1361396829' }
     target = AccessToken.from_hash(client, hash)

     assert_initialized_token(target)
     expect(target.expires_in).to be_a(Integer)
     expect(target.expires_in).to eq 1361396829
    end

    it 'initializes expires_in with params expires_in' do
     hash = { :access_token => token, :expires_in => '1361396829' }
     target = AccessToken.from_hash(client, hash)

     assert_initialized_token(target)
     expect(target.expires_in).to be_a(Integer)
     expect(target.expires_in).to eq 1361396829
    end

    it 'defaults expires_at to Time.now + expires_in_seconds' do
     hash = { :access_token => token, :expires_in_seconds => '1361396829' }
     target = AccessToken.from_hash(client, hash)

     assert_initialized_token(target)
     expect(target.expires_at).to be_a(Integer)
    end

    it 'defaults expires_at to Time.now + expires_in seconds' do
     hash = { :access_token => token, :expires_in => '1361396829' }
     target = AccessToken.from_hash(client, hash)

     assert_initialized_token(target)
     expect(target.expires_at).to be_a(Integer)
    end

    it 'initializes with an array scopes' do
     hash = { :access_token => token, scopes: ['likes', 'ratings'] }
     target = AccessToken.from_hash(client, hash)

     expect(target.scopes).to be_a(Array)
     expect(target.scopes).not_to be_empty
    end

    it 'initializes with an integer resource_owner_id' do
     hash = { :access_token => token, resource_owner_id: 1 }
     target = AccessToken.from_hash(client, hash)

     expect(target.resource_owner_id).to be_a(Integer)
     expect(target.resource_owner_id).to eq 1
    end
  end
end
