require 'spec_helper'

describe ApiController, 'authentication' do
  let(:user) { User.create(name: 'name', password: 'password') }

  context 'successful' do
    before do
      given_resource_owner_will_be_authenticated(user)
    end

    it 'is authenticated to perform action' do
      get :signin_path
      expect(response).to have_http_status(:ok)
    end
  end

  context 'failed' do
    before do
      given_resource_owner_will_not_be_authenticated(user)
    end

    it 'returns an invalid password error message' do
      get :signin_path
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

describe ApiController, 'authorize resource_owner' do
  context 'successful' do
    context 'without scopes' do
      it
    end

    context 'with scopes' do
    end
  end

  context 'failed' do
    context 'without scopes' do
    end

    context 'with scopes' do
    end
  end
end

describe ApiController, 'authorize client application' do
  context 'successful' do
    context 'without scopes' do
      it
    end

    context 'with scopes' do
    end
  end

  context 'failed' do
    context 'without scopes' do
    end

    context 'with scopes' do
    end
  end
end
