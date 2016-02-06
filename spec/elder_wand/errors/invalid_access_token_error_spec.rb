require 'spec_helper'

module ElderWand::Errors
  describe InvalidAccessTokenError do
    let(:token) { ElderWand::AccessToken.new('client', 'access_token') }
    subject(:error) { InvalidAccessTokenError.new(token) }

    it { expect(subject).to respond_to(:status) }
    it { expect(subject).to respond_to(:error_type) }
    it { expect(subject).to respond_to(:reasons) }

    context 'token revoked' do
      it 'maps to the appropriate translation' do
        allow(token).to receive(:revoked?).and_return true
        expect(subject.reasons).to match_array([I18n.t('elder_wand.authorization.invalid_token.revoked')])
      end
    end

    context 'token expired' do
      it 'maps to the appropriate translation' do
        allow(token).to receive(:expired?).and_return true
        expect(subject.reasons).to match_array([I18n.t('elder_wand.authorization.invalid_token.expired')])
      end
    end

    context 'token invalid' do
      it 'maps to the appropriate translation' do
         subject = InvalidAccessTokenError.new(nil)
        expect(subject.reasons).to match_array([I18n.t('elder_wand.authorization.invalid_token.invalid')])
      end
    end

    context 'invalid token scope' do
      it 'maps to the appropriate translation' do
        expect(subject.reasons).to match_array([I18n.t('elder_wand.authorization.invalid_scope')])
      end
    end
  end
end
