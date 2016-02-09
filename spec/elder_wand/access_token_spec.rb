require 'spec_helper'

describe AccessToken do
  let(:token) { 'monkey' }
  let(:client) do
    Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
      builder.request :url_encoded
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
     hash = { access_token: token }
     target = AccessToken.from_hash(client, hash)

     expect(target.token).to eq token
    end

    it 'initializes expires_in with params expires_in_seconds or expires_in' do
     hash = { access_token: token, :expires_in_seconds => '1361396829' }
     target = AccessToken.from_hash(client, hash)

     assert_initialized_token(target)
     expect(target.expires_in).to be_a(Integer)
     expect(target.expires_in).to eq 1361396829
    end

    it 'initializes expires_in with params expires_in' do
     hash = { access_token: token, :expires_in => '1361396829' }
     target = AccessToken.from_hash(client, hash)

     assert_initialized_token(target)
     expect(target.expires_in).to be_a(Integer)
     expect(target.expires_in).to eq 1361396829
    end

    it 'defaults expires_at to Time.now + expires_in_seconds' do
     hash = { access_token: token, :expires_in_seconds => '1361396829' }
     target = AccessToken.from_hash(client, hash)

     assert_initialized_token(target)
     expect(target.expires_at).to be_a(Integer)
    end

    it 'defaults expires_at to Time.now + expires_in seconds' do
     hash = { access_token: token, :expires_in => '1361396829' }
     target = AccessToken.from_hash(client, hash)

     assert_initialized_token(target)
     expect(target.expires_at).to be_a(Integer)
    end

    it 'converts a string containing scopes into an array' do
     hash = { access_token: token, scope: 'likes ratings' }
     target = AccessToken.from_hash(client, hash)

     expect(target.scopes).to be_a(Array)
     expect(target.scopes).to match_array(['likes', 'ratings'])
    end

    it 'intializes scopes to an empty string if :scope is blank' do
      hash = { access_token: token }
      target = AccessToken.from_hash(client, hash)

      expect(target.scopes).to be_a(Array)
      expect(target.scopes).to be_empty
    end

    it 'initializes with an integer resource_owner_id' do
     hash = { access_token: token, resource_owner_id: 1 }
     target = AccessToken.from_hash(client, hash)

     expect(target.resource_owner_id).to be_a(Integer)
     expect(target.resource_owner_id).to eq 1
    end

    it 'initializes with an boolean revoked' do
     hash = { access_token: token, revoked: true }
     target = AccessToken.from_hash(client, hash)

     expect(target.revoked?).to eq true
    end

    it 'initializes with an boolean expired' do
     hash = { access_token: token, expired: true }
     target = AccessToken.from_hash(client, hash)

     expect(target.expired?).to eq true
    end

    it 'defaults expired to revoked to false if not provided' do
      hash = { access_token: token }
      target = AccessToken.from_hash(client, hash)

      expect(target.expired?).to be false
      expect(target.revoked?).to be false
    end
  end

  describe '#includes_scope?' do
    let(:hash) do
      { access_token: token, scope: 'likes ratings' }
    end
    let(:target) { AccessToken.from_hash(client, hash) }

    it 'returns true if the scope is supported' do
      expect(target.includes_scope?('likes', 'ratings')).to be true
    end

    it 'returns true if the input is blank' do
      expect(target.includes_scope?).to be true
    end

    it 'returns true if at least one scope is supported' do
      expect(target.includes_scope?('social', 'likes')).to be true
    end

    it 'returns false if the scope is not supported' do
      expect(target.includes_scope?('invalid')).to be false
    end
  end

  describe '#acceptable?' do
    let(:hash) do
      { access_token: token, scope: 'likes ratings', expired: false, revoked: false }
    end
    let(:target) { AccessToken.from_hash(client, hash) }

    it 'returns true if not expired, not revoked and has no required scopes' do
      expect(target.acceptable?(['likes'])).to be true
    end

    it 'returns true if not expired, not revoked and at least one scope supported' do
      target = AccessToken.from_hash(client, hash)
      expect(target.acceptable?(['likes', 'invalid'])).to be true
    end

    it 'returns true if not expired, not revoked and nil scopes' do
      target = AccessToken.from_hash(client, hash)
      expect(target.acceptable?(nil)).to be true
    end

    it 'returns false if not expired, not revoked and scope is not supported' do
      target = AccessToken.from_hash(client, hash)
      expect(target.acceptable?('invalid')).to be false
    end

    it 'returns false if expired?' do
      hash[:expired] = true
      target = AccessToken.from_hash(client, hash)

      expect(target.expired?).to be true
      expect(target.acceptable?('likes')).to be false
    end

    it 'returns false if revoked?' do
      hash[:revoked] = true
      target = AccessToken.from_hash(client, hash)

      expect(target.revoked?).to be true
      expect(target.acceptable?('likes')).to be false
    end
  end
end
