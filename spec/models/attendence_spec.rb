require 'spec_helper.rb'

describe Attendance do

  describe 'todo?' do
    it 'returns true when pending? is false' do
      attendance = Attendance.new
      attendance.stub(:pending?) { true }
      expect(attendance.todo?).to eq true
    end

    it 'returns false when pending? is false' do
      attendance = Attendance.new
      attendance.stub(:pending?) { false }
      expect(attendance.todo?).to eq false
    end

    it 'returns foo when pending? is foo' do
      attendance = Attendance.new
      attendance.stub(:pending?) { 'foo' }
      expect(attendance.todo?).to eq 'foo'
    end
  end

  describe 'flake!' do
    it 'updates status to :flake' do
      fake_tea = mock_model("TeaTime", {:spots_remaining? => true })

      attendance = Attendance.new(tea_time:  fake_tea)

      attendance.flake!
      expect(attendance.status).to eq "flake"
    end

    it 'saves the record' do
      # TODO use Factory Girl to generate a valid Attendance
      # so this test doesn't need to create an association
      fake_tea = mock_model("TeaTime", {:spots_remaining? => true })

      attendance = Attendance.new(tea_time:  fake_tea)
      attendance.flake!
      expect(attendance.changed?).to eq false
    end
  end
end