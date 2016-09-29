require 'spec_helper'

describe ElderWand, 'configuration' do
  subject { ElderWand.configuration }

  describe 'provider_url' do
    it 'sets the provider url' do
      ElderWand.configure do
        provider_url 'some_url'
      end
      expect(subject.provider_url).to eq 'some_url'
    end
  end

  describe 'redirect_uri' do
    it 'sets the redirect_uri' do
      ElderWand.configure do
        redirect_uri 'some_uri'
      end
      expect(subject.redirect_uri).to eq 'some_uri'
    end
  end

  describe 'default scopes' do
    it 'returns an empty array if not configured' do
      ElderWand.configure {}
      expect(subject.default_scopes).to match_array([])
    end

    it 'sets the default scopes' do
      ElderWand.configure do
        default_scopes :public
      end
      expect(subject.default_scopes).to match_array([:public])
    end
  end

  describe 'resource_owner_from_credentials' do
    it 'raises an error if not configured' do
      ElderWand.configure {}
      expect { subject.resource_owner_from_credentials }.to raise_error(RuntimeError)
    end

    it 'sets the block the appropriate block' do
      block = proc {}
      ElderWand.configure do
        resource_owner_from_credentials &block
      end
      expect(subject.resource_owner_from_credentials).to eq(block)
    end
  end
end
