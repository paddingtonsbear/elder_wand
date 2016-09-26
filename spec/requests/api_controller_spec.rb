require 'spec_helper'

describe ApiController, 'authentication' do
  let(:user)            { User.create(name: 'name', password: 'password') }
  let(:parsed_response) { parse_json(response.body) }
  let(:response_body)   { response.body }

  context 'successful' do
    before do
      given_resource_owner_will_be_authenticated(user)
    end

    it 'is authenticated to perform action' do
      get signin_path, params: { username: 'name', password: 'password' }
      expect(response).to have_http_status(:ok)
    end
  end

  context 'failed' do
    before do
      given_resource_owner_will_not_be_authenticated
      get signin_path
    end

    it 'returns status 401' do
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns an error json body' do
      expect(response_body).to have_json_path('meta')
      expect(response_body).to have_json_path('errors')
      expect(parsed_response['meta']['error_type']).to eq 'invalid_password'
      expect(parsed_response['errors']).to match_array([I18n.t('elder_wand.authentication.invalid_password')])
    end
  end
end

describe ApiController, 'revoke token' do
  let(:user)            { User.create(name: 'name', password: 'password') }
  let(:token)           { 'some_access_token' }
  let(:parsed_response) { parse_json(response.body) }
  let(:response_body)   { response.body }

  context 'successful' do
    it 'is revoked' do
      given_access_token_will_be_revoked
      get signout_path, params: { token: token }
      expect(response).to have_http_status(:ok)
    end
  end

  context 'failed' do
    it 'is not revoked' do
      given_access_token_will_not_be_revoked
      get signout_path, params: { token: token }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

describe ApiController, 'authorize resource_owner' do
  let(:user)            { User.create(name: 'name', password: 'password') }
  let(:parsed_response) { parse_json(response.body) }
  let(:response_body)   { response.body }
  let(:scopes)          { ['public', 'admin'] }

  context 'successful' do
    context 'without scopes' do
      it 'is authorized to perform an action' do
        given_resource_owner_will_be_authorized(resource_owner_id: user.id)
        get resource_path
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with scopes' do
      it 'is authorized to perform an action' do
        opts = {
          resource_owner_id: user.id,
          scopes: scopes
        }
        given_resource_owner_will_be_authorized(opts)
        get resource_with_scope_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'failed' do
    context 'without scopes' do
      before do
        given_resource_owner_will_not_be_authorized
        get resource_path
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error json body' do
        expect(response_body).to have_json_path('meta')
        expect(response_body).to have_json_path('errors')
        expect(parsed_response['meta']['error_type']).to eq 'invalid'
        expect(parsed_response['errors']).not_to be_empty
      end
    end

    context 'with expired access token' do
      before do
        opts = {
          resource_owner_id: user.id,
          expired: true,
          scopes: scopes
        }
        given_resource_owner_will_be_authorized(opts)
        get resource_with_scope_path
      end

      it 'returns status 403' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'returns an error json body' do
        expect(response_body).to have_json_path('meta')
        expect(response_body).to have_json_path('errors')
        expect(parsed_response['meta']['error_type']).to eq 'invalid_token'
        expect(parsed_response['errors']).to match_array([I18n.t('elder_wand.authorization.invalid_token.expired')])
      end
    end

    context 'with revoked access token' do
      before do
        opts = {
          resource_owner_id: user.id,
          revoked: true,
          scopes: scopes,
        }
        given_resource_owner_will_be_authorized(opts)
        get resource_with_scope_path
      end

      it 'returns status 403' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'returns an error json body' do
        expect(response_body).to have_json_path('meta')
        expect(response_body).to have_json_path('errors')
        expect(parsed_response['meta']['error_type']).to eq 'invalid_token'
        expect(parsed_response['errors']).to match_array([I18n.t('elder_wand.authorization.invalid_token.revoked')])
      end
    end

    context 'with invalid scopes' do
      before do
        opts = {
          resource_owner_id: user.id,
          scopes: ['invalid scopes']
        }
        given_resource_owner_will_be_authorized(opts)
        get resource_with_scope_path
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error json body' do
        expect(response_body).to have_json_path('meta')
        expect(response_body).to have_json_path('errors')
        expect(parsed_response['meta']['error_type']).to eq 'invalid_scope'
        expect(parsed_response['errors']).to match_array([I18n.t('elder_wand.authorization.invalid_scope')])
      end
    end
  end
end

describe ApiController, 'authorize client application' do
  let(:user)            { User.create(name: 'name', password: 'password') }
  let(:parsed_response) { parse_json(response.body) }
  let(:response_body)   { response.body }
  let(:scopes)          { ['public', 'admin'] }

  context 'successful' do
    context 'without scopes' do
      it 'is authorized to perform an action' do
        given_client_application_will_be_authorized(resource_owner_id: user.id)
        get client_path
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with scopes' do
      it 'is authorized to perform an action' do
        opts = {
          resource_owner_id: user.id,
          scopes: scopes
        }
        given_client_application_will_be_authorized(opts)
        get client_with_scope_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'failed' do
    context 'without scopes' do
      before do
        given_client_application_will_not_be_authorized
        get client_path
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error json body' do
        expect(response_body).to have_json_path('meta')
        expect(response_body).to have_json_path('errors')
        expect(parsed_response['meta']['error_type']).to eq 'invalid'
        expect(parsed_response['errors']).not_to be_empty
      end
    end

    context 'with invalid scopes' do
      before do
        opts = {
          resource_owner_id: user.id,
          scopes: ['invalid scopes']
        }
        given_client_application_will_be_authorized(opts)
        get client_with_scope_path
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error json body' do
        expect(response_body).to have_json_path('meta')
        expect(response_body).to have_json_path('errors')
        expect(parsed_response['meta']['error_type']).to eq 'invalid_client'
        expect(parsed_response['errors']).to match_array([I18n.t('elder_wand.authorization.invalid_client')])
      end
    end
  end
end
