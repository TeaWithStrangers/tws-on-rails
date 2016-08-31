require 'spec_helper'

describe HostMailer do
  describe '.pre_tea_time_nudge' do
    let(:host) do
      u = create(:user)
      u.roles << :host
      u
    end
    let(:tea_time_id) do
      create(:tea_time, user_id: host.id).id
    end

    let(:cancelled_tea_time) do
      create(:tea_time, user_id: host.id, followup_status: :cancelled)
    end

    let(:mail) do
      described_class.pre_tea_time_nudge(tea_time_id)
    end

    let(:cancelled_mail) do
      described_class.pre_tea_time_nudge(cancelled_tea_time.id)
    end

    it 'should not send for cancelled tea time' do
      cancelled_mail.deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'should be from the default address' do
      expect(mail.from).to eq ["sayhi@teawithstrangers.com"]
    end

    it 'should be to the host' do
      expect(mail.to).to eq [host.email]
    end

    describe 'body' do
      describe 'html_part' do
        it 'should exist' do
          expect(mail.html_part.body.raw_source).not_to be_empty
        end
      end
      describe 'text_part' do
        it 'should exist' do
          expect(mail.text_part.body.raw_source).not_to be_empty
        end
      end
    end
  end
end
