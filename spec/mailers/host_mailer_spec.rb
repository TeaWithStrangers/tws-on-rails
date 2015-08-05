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

    let(:mail) do
      described_class.pre_tea_time_nudge(tea_time_id)
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
