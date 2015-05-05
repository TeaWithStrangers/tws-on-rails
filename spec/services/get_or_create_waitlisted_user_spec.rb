require 'spec_helper.rb'

describe GetOrCreateWaitlistedUser do
  context '#call' do
    let(:params) { {email: 'barf@eagle5.com', nickname: 'Barf'} }
    let!(:returned) { subject.call(params) }
    end
  end
end
