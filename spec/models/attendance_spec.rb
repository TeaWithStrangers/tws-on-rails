require 'spec_helper.rb'

describe Attendance do
  describe 'todo?' do
    it 'returns true when pending? is false' do
      attendance = create(:attendance)
      expect(attendance.todo?).to eq true
    end

    it 'returns false when pending? is false' do
      attendance = create(:attendance, :flake)
      expect(attendance.todo?).to eq false
    end

    it 'returns foo when pending? is foo' do
      attendance = Attendance.new
      attendance.stub(:pending?) { 'foo' }
      expect(attendance.todo?).to eq 'foo'
    end
  end

  describe 'flake!' do
    before(:each) do
      @tt = create(:tea_time, :full)
    end

    let(:attendance) { create(:attendance, tea_time: @tt) }

    it 'updates status to :flake' do
      attendance.flake!
      expect(attendance.status).to eq "flake"
      expect(attendance.changed?).to eq false
    end

    it 'fires off waitlist notifications' do
      tt = double('TeaTime', spots_remaining?: false)
      [:send_waitlist_notifications, :persisted?].each {|m|
        allow(tt).to receive m
      }
      expect(tt).to receive(:send_waitlist_notifications)

      attendance.stub(:tea_time) { tt }
      attendance.flake!
    end
  end

  describe '.user' do
    let(:attendance) { create(:attendance, user: nil)}
    it 'should return a nil_user instance if its user is deleted' do
      expect(attendance.user).to eql User.nil_user
    end
  end
end
