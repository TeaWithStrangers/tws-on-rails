require 'spec_helper.rb'

describe Attendance do
  it { expect(subject).to delegate_method(:start_time).to(:tea_time).with_prefix(true) }

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

    it 'accepts an optional reason and flakes' do
      reason = "Yogurt isn't attending"
      attendance.flake!({reason: reason})
      expect(attendance.flake?).to eq true
      expect(attendance.reason).to eq reason
    end

    it 'fires off waitlist notifications' do
      tt = double('TeaTime', spots_remaining?: false, marked_for_destruction?: false)
      [:send_waitlist_notifications, :persisted?].each {|m|
        allow(tt).to receive m
      }
      expect(tt).to receive(:send_waitlist_notifications)

      attendance.stub(:tea_time) { tt }
      attendance.flake!
    end
  end

  describe '.queue_first_reminder' do
    let!(:attendance) { build(:attendance) }

    it 'should not first second reminder after the tea time has started' do
      Time.stub(:now).and_return(attendance.tea_time.start_time + 1.hour)
      dj_count = Delayed::Job.count
      attendance.queue_first_reminder
      expect(Delayed::Job.count).to eq(dj_count)
    end

    it 'should not queue first reminder less than 48 hours before' do
      Time.stub(:now).and_return(attendance.tea_time.start_time - 36.hour)
      dj_count = Delayed::Job.count
      attendance.queue_first_reminder
      expect(Delayed::Job.count).to eq(dj_count)
    end

    it 'should queue first reminder 50 hours before' do
      Time.stub(:now).and_return(attendance.tea_time.start_time - 50.hour)
      dj_count = Delayed::Job.count
      attendance.queue_first_reminder
      expect(Delayed::Job.count).to eq(dj_count += 1)
    end
  end

  describe '.queue_second_reminder' do
    let!(:attendance) { build(:attendance) }

    it 'should not queue second reminder after the tea time has started' do
      Time.stub(:now).and_return(attendance.tea_time.start_time + 1.hour)
      dj_count = Delayed::Job.count
      attendance.queue_second_reminder
      expect(Delayed::Job.count).to eq(dj_count)
    end

    it 'should not queue second reminder less than 12 hours before' do
      Time.stub(:now).and_return(attendance.tea_time.start_time - 8.hour)
      dj_count = Delayed::Job.count
      attendance.queue_second_reminder
      expect(Delayed::Job.count).to eq(dj_count)
    end

    it 'should queue the second reminder more than 12 hours before' do
      Time.stub(:now).and_return(attendance.tea_time.start_time - 13.hour)
      dj_count = Delayed::Job.count
      attendance.queue_second_reminder
      expect(Delayed::Job.count).to eq(dj_count += 1)
    end
  end

  describe '.user' do
    let(:attendance) { build(:attendance, user: nil)}
    it 'should return a nil_user instance if its user is deleted' do
      expect(attendance.user).to eql User.nil_user
    end
  end
end
