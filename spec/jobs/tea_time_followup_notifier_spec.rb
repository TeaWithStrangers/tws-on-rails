require 'spec_helper.rb'

describe TeaTimeFollowupNotifier do
  let(:tt) { create(:tea_time, :mixed) }
  let(:waitlist_only_tt) { create(:tea_time, :empty_waitlist) }
  let(:cancelled_tt) { create(:tea_time, :cancelled) }

  describe '.perform' do
    it 'should send a mail per attendance group (flake, attendee, &c.)' do
      TeaTimeFollowupNotifier.new(tt).perform
      expect(ActionMailer::Base.deliveries.count).to eq 3
    end

    it 'should not send mail to waitlisted attendees' do
      TeaTimeFollowupNotifier.new(waitlist_only_tt).perform
      TeaTimeFollowupNotifier.new(cancelled_tt).perform
      expect(ActionMailer::Base.deliveries.count).to eq 0
    end
  end
end

