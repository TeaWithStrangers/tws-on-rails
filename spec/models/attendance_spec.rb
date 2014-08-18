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
      AttendanceMailer.stub(:flake)
      @tt = create(:tea_time)
    end
    it 'updates status to :flake' do
      attendance = create(:attendance, tea_time: @tt)

      attendance.flake!
      expect(attendance.status).to eq "flake"
    end

    it 'saves the record' do
      attendance = create(:attendance, tea_time: @tt)
      attendance.flake!
      expect(attendance.changed?).to eq false
    end
  end
end
