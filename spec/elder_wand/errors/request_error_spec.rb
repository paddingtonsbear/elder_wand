require 'spec_helper'

module ElderWand::Errors
  describe RequestError do
    let(:headers) do
      { 'Content-Type' => 'application/json' }
    end
    let(:body) do
      MultiJson.encode(
        meta: {
          code: 401,
          error_type: 'invalid'
        },
        reasons: ['some errors']
      )
    end
    let(:response) do
      r = double('response', status: 401, headers: headers, body: body)
      OAuth2::Response.new(r)
    end

    subject(:error) { RequestError.new(response) }

    it { expect(subject).to respond_to(:status) }
    it { expect(subject).to respond_to(:error_type) }
    it { expect(subject).to respond_to(:reason) }
    it { expect(subject).to respond_to(:response) }
  end
end
