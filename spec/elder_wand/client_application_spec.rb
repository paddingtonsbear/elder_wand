require 'spec_helper'

describe ClientApplication do
  let(:client) do
    Client.new('abc', 'def', :site => 'https://api.example.com') do |builder|
      builder.request :url_encoded
    end
  end
  let(:hash) do
    {}
  end
  let(:target) { ClientApplication.from_hash(client, hash) }

  describe '#initialize' do
    it 'assigns client' do
      expect(target.client).to eq(client)
    end

    it 'initializes uid with params :uid' do
      hash[:client_id] = 'some_uid'
      expect(target.client_id).to eq 'some_uid'
    end

    it 'initializes name with params :name' do
      hash[:name] = 'some_name'
      expect(target.name).to eq 'some_name'
    end

    it 'initializes secret with params :secret' do
      hash[:client_secret] = 'secret'
      expect(target.client_secret).to eq 'secret'
    end

    it 'converts a string containing scopes into an array' do
      hash[:scopes] = ['likes', 'ratings']
      expect(target.scopes).to be_a(Array)
      expect(target.scopes).to match_array(['likes', 'ratings'])
    end

    it 'initializes scopes with an empty array if param :scopes blank' do
      hash[:scopes] = nil
      expect(target.scopes).to be_a(Array)
    end
  end

  describe '#includes_scope?' do
    let(:hash) do
      { scopes: ['likes', 'ratings'] }
    end

    it 'returns true if the scope is supported' do
      expect(target.includes_scope?(['likes', 'ratings'])).to be true
    end

    it 'returns true if the input is blank' do
      expect(target.includes_scope?).to be true
    end

    it 'returns true if at least one scope is supported' do
      expect(target.includes_scope?(['social', 'likes'])).to be true
    end

    it 'returns false if the scope is not supported' do
      expect(target.includes_scope?(['invalid'])).to be false
    end
  end
end
