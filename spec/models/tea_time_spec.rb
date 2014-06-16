require 'spec_helper.rb'

describe TeaTime do
  describe '.attendees' do
    it 'should return the User objects of attendees' do
      tea_time = create(:tt_with_attendees)
      expect(tea_time.attendees.count).to eq(3)
    end
  end
  describe '.spots_remaining?' do
    it 'should return true if fewer than MAX_ATTENDEES are registered' do
      tea_time = create(:tt_with_attendees)
      expect(tea_time.spots_remaining?).to eq(true)
    end

    it 'should return false if MAX_ATTENDEES are registered' do
      tea_time = create(:tt_with_attendees, :full)
      expect(tea_time.spots_remaining?).to eq(false)
    end
  end

  describe '.friendly_time' do
    before(:each) do
      @tea_time = TeaTime.new
    end

    it 'should only display mintues if tea time does not begin/end on the hour' do
      @tea_time.stub(start_time: DateTime.new(2014,1,1, 12, 30),
                    duration: 2)
      expect(@tea_time.friendly_time).to include("12:30-2:30pm")
    end

    it 'should not display mintues if tea time does begin/end on the hour' do
      @tea_time.stub(start_time: DateTime.new(2014,1,1,12),
                    duration: 2)
      expect(@tea_time.friendly_time).not_to include(":")
      expect(@tea_time.friendly_time).to include("12-2pm")

    end

    it 'should display minutes for only one of start/end if only one of start/end is not on the hour' do
      @tea_time.stub(start_time: DateTime.new(2014,1,1,12, 30),
                    duration: 1.5)
      expect(@tea_time.friendly_time).to include("12:30-2pm")
    end
  end

  describe 'all_attendee_emails' do
    it 'should concatenate email addresses of attendees' do
      tea_time = TeaTime.new
      tea_time.stub(attendees: [
        mock_model('User', email: 'foo@tws.com'),
        mock_model('User', email: 'bar@tws.com'),
        mock_model('User', email: 'baz@tws.com'),
      ])
      expect(tea_time.all_attendee_emails).to eq('foo@tws.com,bar@tws.com,baz@tws.com')
    end
  end
end
