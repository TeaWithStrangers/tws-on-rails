require 'spec_helper'

describe HostMailer do
  let(:host) { create(:user, :host) }
  let(:tea_time_id) { create(:tea_time, user_id: host.id).id }

  describe '.pre_tea_time_nudge' do
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

  describe '.host_drip' do
    before(:each) do
      hd = host.host_detail
      hd.commitment = 5
      hd.save!
    end

    it 'doesn\'t send without tt' do
      described_class.host_drip(tea_time_id + 1, 0).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'doesn\'t send if host has irregular commitmnet' do
      hd = host.host_detail
      hd.commitment = -1
      hd.save!
      described_class.host_drip(tea_time_id, 0).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'sends first reminder' do
      mail = described_class.host_drip(tea_time_id, 0)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("Your next tea time")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'sends second reminder' do
      mail = described_class.host_drip(tea_time_id, 1)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("Hi there")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'sends third reminder' do
      mail = described_class.host_drip(tea_time_id, 2)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("Moving oolong 🍵")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'sends repeating reminder' do
      mail = described_class.host_drip(tea_time_id, 5)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("🤗: Knock knock! 🤔: Who’s there?")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end

  describe '.host_drip_reminder' do
    before(:each) do
      hd = host.host_detail
      hd.commitment = 5
      hd.save!
    end

    it 'doesn\'t send without tt' do
      described_class.host_drip_reminder(tea_time_id + 1, 0).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'doesn\'t send if host has irregular commitmnet' do
      hd = host.host_detail
      hd.commitment = -1
      hd.save!
      described_class.host_drip_reminder(tea_time_id, 0).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'sends first reminder' do
      mail = described_class.host_drip_reminder(tea_time_id, 0)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("Your next tea time")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'sends third reminder' do
      mail = described_class.host_drip_reminder(tea_time_id, 2)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("Moving oolong 🍵")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end

  describe '.no_commitment_drip' do
    before(:each) do
      hd = host.host_detail
      hd.commitment = 0
      hd.save!
    end

    it 'doesn\'t send without tt' do
      described_class.no_commitment_drip(tea_time_id + 1, 0).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'doesn\'t send if host has a commitment' do
      hd = host.host_detail
      hd.commitment = 4
      hd.save!
      described_class.no_commitment_drip(tea_time_id, 0).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'sends first reminder' do
      mail = described_class.no_commitment_drip(tea_time_id, 0)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("Thinking about ya")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'sends repeating reminder' do
      mail = described_class.no_commitment_drip(tea_time_id, 5)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("It’s been a while!")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end

  describe '.no_commitment_drip_reminder' do
    before(:each) do
      hd = host.host_detail
      hd.commitment = 0
      hd.save!
    end

    it 'doesn\'t send without host' do
      described_class.no_commitment_drip_reminder(host.id + 1).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'doesn\'t send if host has a commitment' do
      hd = host.host_detail
      hd.commitment = 4
      hd.save!
      described_class.no_commitment_drip_reminder(host.id).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'sends first reminder' do
      mail = described_class.no_commitment_drip_reminder(host.id)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("Thinking about ya")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end

  describe '.pause' do
    before(:each) do
      hd = host.host_detail
      hd.commitment = -1
      hd.save!
    end

    it 'doesn\'t send without host' do
      described_class.pause(host.id + 1).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'doesn\'t send if not inactive commitment' do
      hd = host.host_detail
      hd.commitment = 4
      hd.save!
      described_class.pause(host.id).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'sends' do
      mail = described_class.pause(host.id)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("We just heard the news…")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end

  describe '.inactive_host_posted' do
    before(:each) do
      hd = host.host_detail
      hd.commitment = -1
      hd.save!
      tt = TeaTime.find(tea_time_id)
      tt.start_time = Time.now + 1.day
      tt.save!
    end

    it 'doesn\'t send without host' do
      described_class.inactive_host_posted(host.id + 1).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'doesn\'t send if not inactive commitment' do
      hd = host.host_detail
      hd.commitment = 4
      hd.save!
      described_class.inactive_host_posted(host.id).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'doesn\'t send if no future teas posted' do
      tt = TeaTime.find(tea_time_id)
      tt.start_time = Time.now - 1.day
      tt.save!
      described_class.inactive_host_posted(host.id).deliver
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'sends' do
      mail = described_class.inactive_host_posted(host.id)
      mail.deliver
      expect(mail.to).to eq [host.email]
      expect(mail.subject).to eql("Hello again!")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end
end
