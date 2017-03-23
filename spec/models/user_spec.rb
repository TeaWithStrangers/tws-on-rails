require 'spec_helper'

describe User do
  it { expect(subject).to validate_presence_of(:nickname) }

  # TODO this will probably become has_many some day
  it { expect(subject).to have_one(:email_reminder) }

  context 'names' do
    let(:user) { create(:user) }

    describe '.name' do
      it 'should proxy to nickname' do
        expect(user.name).to eq(user.nickname)
      end
    end
  end

  context 'roles' do
    let(:admin) { create(:user, :admin) }
    let(:host) { create(:user, :host) }
    let(:user) { create(:user) }

    describe '.admin?' do
      it 'should return false for non-admins' do
        expect(host.admin?).to eq(false)
        expect(user.admin?).to eq(false)
      end

      it 'should return true for an admin' do
        expect(admin.admin?).to eq(true)
      end
    end

    describe '.host?' do
      it 'should return true for an admin' do
        expect(admin.host?).to eq(true)
      end

      it 'should return true for an host' do
        expect(host.host?).to eq(true)
      end
    end
  end

  describe 'facebook' do
    it 'should be able to store a string as a facebook' do
      user = FactoryGirl.create(:user, facebook: 'hoo')
      expect(user.facebook).to eq 'hoo'
      expect(user.id).to_not be_nil
    end

    it 'should not include the http' do
      user = User.create(facebook: 'http://foo')
      expect(user.errors.messages[:facebook]).to include "should not include http(s)"
    end

    it 'should not include https' do
      user = User.create(facebook: 'https://foo')
      expect(user.errors.messages[:facebook]).to include "should not include http(s)"
    end

    it 'should not include facebook.com' do
      user = User.create(facebook: 'www.facebook.com')
      expect(user.errors.messages[:facebook]).to include "should not include facebook.com"
    end
  end

  describe '#facebook_url' do
    it 'prefixes facebook id with schema' do
      facebook_id = 'foobarbaz'
      user = User.new(facebook: facebook_id)
      expect(user.facebook_url).to eq "https://facebook.com/#{facebook_id}"
    end
    it 'returns nil if user does not have a facebook id' do
      user = User.new(facebook: nil)
      expect(user.facebook_url).to eq nil
    end
  end

  describe '#twitter_url' do
    it 'prefixes twitter handle with schema' do
      handle = "twstrangers"
      user = User.new(twitter: handle)
      expect(user.twitter_url).to eq "https://twitter.com/#{handle}"
    end
    it 'returns nil if user does not have a twitter handle' do
      user = User.new(twitter: nil)
      expect(user.twitter_url).to eq nil
    end
  end

  describe 'twitter' do
    it 'should be able to store a string as a twitter handle' do
      user = User.new(twitter: 'blablah')
      expect(user.twitter).to eq 'blablah'
    end

    it 'should not contain special characters' do
      user = User.create(twitter: '@asda!^7')
      expect(user.errors.messages[:twitter]).to include 'not a valid twitter handle'
    end
  end

  context 'Waitlisting:' do
    let(:user) { create(:user) }
    let(:wl_user) { create(:user, :waitlist) }

    it "doesn't treat existing users as waitlisted" do
      expect(user.waitlisted?).to eq false
    end

    context "modification" do
      describe ".waitlist" do
        it "should set WL status and wl'ed_at" do
          user.waitlist
          expect(user.waitlisted?).to eq true
          expect(user.waitlisted_at).not_to eq nil
        end

        it "should not modify an already waitlisted user" do
          expect(wl_user.waitlisted?).to eq true
        end
      end

      describe ".unwaitlist" do
        it "should set WL status and wl'ed_at" do
          wl_user.unwaitlist
          expect(wl_user.waitlisted?).to eq false
          expect(wl_user.unwaitlisted_at).not_to eq nil
        end

        it "should not modify a non-waitlisted user" do
          user.unwaitlist
          expect(user.waitlisted?).to eq false
        end
      end
    end
  end

  describe '.flake_future' do
    let(:tt) { create(:tea_time, attendee_count: 1) }
    let(:user) { tt.attendances.first.user }
    let(:past_att) {
      past_tt = create(:tea_time, :past)
      create(:attendance, tea_time: past_tt, user: user)
    }

    it 'should flake all future attendances' do
      user.flake_future
      expect(user.attendances.first.flake?).to eq(true)
    end

    it 'should ignore past attendances' do
      user.flake_future
      expect(past_att.status).not_to eq(:flake)
    end
  end

  context 'host commitment' do
    let(:host) { create(:user, :host) }
    let(:host_detail) { host.host_detail }

    context 'overview' do
      it 'is inactive if host is inactive' do
        host_detail.commitment = HostDetail::INACTIVE_COMMITMENT
        host_detail.save!
        expect(host.commitment_overview).to eql HostDetail::INACTIVE_COMMITMENT
      end

      it 'is 0 if host is paused' do
        host_detail.commitment = 0
        host_detail.save!
        expect(host.commitment_overview).to eql 0
      end

      it 'is REGULAR_COMMITMENT if commitment is, for example, monthly' do
        host_detail.commitment = 4
        host_detail.save!
        expect(host.commitment_overview).to eql HostDetail::REGULAR_COMMITMENT
      end

      it 'is REGULAR_COMMITMENT if commitment is anything else' do
        host_detail.commitment = 7
        host_detail.save!
        expect(host.commitment_overview).to eql HostDetail::REGULAR_COMMITMENT
      end

      it 'does not save if it\'s a regular commitment' do
        # `detail` takes care of this instead
        host_detail.commitment = 7
        host_detail.save!
        host.commitment_overview = HostDetail::REGULAR_COMMITMENT
        expect(host_detail.reload.commitment).to eql 7
      end

      it 'does save if it\'s inactive commitment' do
        host_detail.commitment = 7
        host_detail.save!
        host.commitment_overview = HostDetail::INACTIVE_COMMITMENT
        expect(host_detail.reload.commitment).to eql HostDetail::INACTIVE_COMMITMENT
      end

      it 'does save if it\'s pause commitment' do
        host_detail.commitment = 7
        host_detail.save!
        host.commitment_overview = 0
        expect(host_detail.reload.commitment).to eql 0
      end
    end

    context 'detail' do
      it 'doesn\'t save negative numbers' do
        host_detail.commitment = 7
        host_detail.save!
        host.commitment_detail = -5
        expect(host_detail.reload.commitment).to eql 7
      end

      it 'doesn\'t save nonintegers' do
        host_detail.commitment = 7
        host_detail.save!
        host.commitment_detail = "hello"
        expect(host_detail.reload.commitment).to eql 7
      end

      it 'does save positive integers' do
        host_detail.commitment = 7
        host_detail.save!
        host.commitment_detail = 5
        expect(host_detail.reload.commitment).to eql 5
      end
    end
  end

  context '.send_drip_email' do
    let!(:host) { create(:user, :host) }
    context 'does not send' do
      it 'with inactive commitment' do
        expect(ActionMailer::Base.deliveries.size).to eq(0)
        host.host_detail.destroy
        create(:host_detail, :user => host, :commitment => HostDetail::INACTIVE_COMMITMENT)
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 3.weeks)
        host.send_drip_email(tea_time)
      end

      it 'with no commitment' do
        expect(ActionMailer::Base.deliveries.size).to eq(0)
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 3.weeks)
        host.send_drip_email(tea_time)
      end

      it 'with no tea time' do
        host.host_detail.destroy
        create(:host_detail, :user => host, :commitment => HostDetail::NO_COMMITMENT)
        expect(ActionMailer::Base.deliveries.size).to eq(0)
        host.send_drip_email(nil)
      end
    end

    context 'with every 4 weeks commitment' do
      before(:each) do
        host.host_detail.destroy
        create(:host_detail, :user => host, :commitment => 4)
      end

      it 'sends first email after 2 weeks' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 2.weeks)
        expect(HostMailer).to receive(:host_drip).with(tea_time.id, 0).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends first reminder after 2 weeks and 2 days' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 2.weeks - 2.days)
        expect(HostMailer).to receive(:host_drip_reminder).with(tea_time.id, 0).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends second email after 4 weeks' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 4.weeks)
        expect(HostMailer).to receive(:host_drip).with(tea_time.id, 1).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends third email after 6 weeks' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 6.weeks)
        expect(HostMailer).to receive(:host_drip).with(tea_time.id, 2).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends third reminder after 6 weeks and 2 days' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 6.weeks - 2.days)
        expect(HostMailer).to receive(:host_drip_reminder).with(tea_time.id, 2).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends recurring reminder after 8 weeks' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 8.weeks)
        expect(HostMailer).to receive(:host_drip).with(tea_time.id, 3).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends recurring reminder after 24 weeks' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 24.weeks)
        expect(HostMailer).to receive(:host_drip).with(tea_time.id, 7).and_call_original
        host.send_drip_email(tea_time)
      end
    end

    context 'with no commitment' do
      before(:each) do
        host.host_detail.destroy
        create(:host_detail, :user => host, :commitment => HostDetail::NO_COMMITMENT)
      end

      it 'sends first email after 3 weeks' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 3.weeks)
        expect(HostMailer).to receive(:no_commitment_drip).with(tea_time.id, 0).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends first reminder after 3 weeks + 2 days' do
        expect(HostMailer).to receive(:no_commitment_drip_reminder).with(host.id).and_call_original
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 3.weeks - 2.days)
        host.send_drip_email(tea_time)
      end

      it 'sends recurring reminder after 3 months' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 3.months)
        expect(HostMailer).to receive(:no_commitment_drip).with(tea_time.id, 1).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends recurring reminder after 6 months' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 6.months)
        expect(HostMailer).to receive(:no_commitment_drip).with(tea_time.id, 2).and_call_original
        host.send_drip_email(tea_time)
      end

      it 'sends recurring reminder after 15 months' do
        tea_time = create(:tea_time, :completed, :host => host, :start_time => Time.now - 15.months)
        expect(HostMailer).to receive(:no_commitment_drip).with(tea_time.id, 5).and_call_original
        host.send_drip_email(tea_time)
      end
    end
  end
end
