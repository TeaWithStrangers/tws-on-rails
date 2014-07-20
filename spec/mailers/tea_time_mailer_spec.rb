require 'spec_helper'

describe TeaTimeMailer do
  before(:all) do
    @tt = create(:tea_time)
    @attendance = create(:attendance, tea_time: @tt)
  end

  describe '.host_confirmation' do
    let(:mail) {
      TeaTimeMailer.host_confirmation(@tt)
    }

    it 'renders the subject' do
      expect(mail.subject).to match(@tt.friendly_time)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([@tt.host.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(["sayhi@teawithstrangers.com"])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(@tt.host.name)
    end
  end
end
