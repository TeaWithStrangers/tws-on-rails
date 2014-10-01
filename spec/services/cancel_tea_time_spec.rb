require 'spec_helper.rb'

describe CancelTeaTime do
  let(:tt) { create(:tea_time, :attended) }
  let(:flake) { create(:attendance, :flake, tea_time: tt) }

  describe '#call' do
    it 'should cancel the tea time and associated attendances' do
      CancelTeaTime.call(tt)
      expect(tt.cancelled?).to eq true
      expect(tt.attendances.first.cancelled?).to eq true
    end
  end

  describe '#send_cancellations' do
    it 'should send cancellations to affected attendees' do
      CancelTeaTime.send_cancellations(tt)
      expect(ActionMailer::Base.deliveries.count).to eq tt.attendances.select(&:pending?).count
      expect(ActionMailer::Base.deliveries.map(&:to)).not_to include(flake.user.email)
    end
  end
end
