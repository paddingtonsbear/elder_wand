require 'spec_helper'

module ElderWand::Errors
  describe ElderWandError do
    subject(:error) { ElderWandError.new }

    it { expect(subject).to respond_to(:status) }
    it { expect(subject).to respond_to(:error_type) }
    it { expect(subject).to respond_to(:reasons) }
    it { expect(subject).to respond_to(:response) }
  end
end
