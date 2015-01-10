require 'spec_helper'

describe TeaTimeMailer do
  before(:all) do
    @tt = create(:tea_time)
    @attendance = create(:attendance, tea_time: @tt)
    @attendance2 = create(:attendance, tea_time: @tt)
  end

  describe '#host_confirmation' do
    let(:mail) { TeaTimeMailer.host_confirmation(@tt) }

    # it 'renders the subject' do
    #   expect(mail.subject).to match(@tt.friendly_time)
    # end

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

  describe '#host_changed' do
    let!(:mail) { TeaTimeMailer.host_changed(@tt, create(:user, :host)).deliver }

    it 'gets delivered without error' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end
  end

  describe '#followup' do
    let(:statuses) { ['flake', 'no_show', 'present'] }
    it 'sets template based on the passed in status' do
      mails = statuses.inject({}) do |hsh, s|
        hsh[s] = TeaTimeMailer.send(:new, 'followup', @tt, @tt.attendances, s)
        hsh
      end
    #TODO: Monkeypatch `assigns` into all Mailer test contexts so we don't need
    #to use this hack
      mails.each do |status, mail|
        expect(mail.view_assigns.with_indifferent_access[:template]).to eq "followup_#{status}"
      end
    end
  end

  describe '#cancellation' do
    let!(:mail) { TeaTimeMailer.cancellation(@tt, @tt.attendances.sample).deliver }

    it 'gets delivered without error' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end
  end

  describe '#ethos' do
    let!(:mail) { TeaTimeMailer.ethos(@tt.host).deliver }

    it 'gets delivered without error' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end
  end
end
