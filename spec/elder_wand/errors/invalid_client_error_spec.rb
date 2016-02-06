require 'spec_helper'

module ElderWand::Errors
  describe InvalidClientError do
    subject(:error) { InvalidClientError.new }

    it { expect(subject).to respond_to(:status) }
    it { expect(subject).to respond_to(:error_type) }
    it { expect(subject).to respond_to(:reasons) }

    describe 'reason' do
      it 'maps to the appropriate translation' do
        expect(subject.reasons).to match_array([I18n.t('elder_wand.authorization.invalid_client')])
      end
    end
  end
end
