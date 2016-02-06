require 'spec_helper'

module ElderWand::Errors
  describe InvalidPasswordError do
    subject(:error) { InvalidPasswordError.new }

    it { expect(subject).to respond_to(:status) }
    it { expect(subject).to respond_to(:error_type) }
    it { expect(subject).to respond_to(:reasons) }

    describe 'reason' do
      it 'maps to the appropriate translation' do
        expect(subject.reasons).to match_array([I18n.t('elder_wand.authentication.invalid_password')])
      end
    end
  end
end
