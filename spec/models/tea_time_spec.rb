require 'spec_helper.rb'

describe TeaTime do
  describe 'persistence' do
    before(:each) do
      @city_pst = create(:city)
      @city_est = create(:city, timezone: "Eastern Time (US & Canada)")
      @city_utc = create(:city, timezone: "UTC")
      #@items = [city_utc, city_pst, city_est].inject({}) {|hsh, c|
      #  hsh[c] = create(:tea_time, city: c)
      #  hsh
      #}
    end

    it 'should save time as UTC, account for the city TZ difference' do
      tt = create(:tea_time, city: @city_pst)
      tt.start_time = Time.new(2014,1,1,16)
      expect(tt.start_time.utc).to eq(Time.utc(2014,1,2))
    end

    it 'should save time as UTC, account for the city TZ difference via .update' do
      tt = create(:tea_time, city: @city_pst)
      tt.update(start_time: Time.local(2014,1,1,16))
      expect(tt.start_time.utc).to eq(Time.utc(2014,1,2))
    end


    it 'should always interpret times as taking place in the associated city' do
      tt = create(:tea_time, city: @city_est)
      tt.start_time = Time.local(2014,1,1,16)
      expect(tt.start_time.utc).to eq(Time.utc(2014,1,1,21))
    end

    it 'should adjust to maintain the same *local* time if switched between timezones/cities' do
      tt = create(:tea_time, city: @city_est, start_time: Time.utc(2014,1,1,16))
      expect(tt.start_time.utc).to eq Time.utc(2014,1,1,21)
      tt.city = @city_pst
      expect(tt.start_time.utc).to eq Time.utc(2014,1,2)
    end
  end

  describe 'scopes' do
    before(:all) do
      @past_tt = create(:tea_time, :past)
      @tt = create(:tea_time)
    end
    describe '#past' do
      it 'should only include past tea times' do
        expect(TeaTime.past).to include(@past_tt)
        expect(TeaTime.past).not_to include(@tt)
      end
    end

    describe '#future' do
      it 'should only include future tea times' do
        expect(TeaTime.future).not_to include(@past_tt)
        expect(TeaTime.future).to include(@tt)
      end
    end

    describe '#future_until' do
      it 'should only include future tea times up to a given date' do
        @far_future_tt = create(:tea_time, start_time: @tt.start_time+1.year)
        until_date = @tt.start_time+1.day
        expect(TeaTime.future_until(until_date)).not_to include(@past_tt, @far_future_tt)
        expect(TeaTime.future_until(until_date)).to include(@tt)
      end
    end

    describe '- followup_status' do
      before(:each) do
        @cancelled = create(:tea_time, :cancelled)
      end

      describe '#na' do
        it 'should only include tea times with na status' do
          expect(TeaTime.na).not_to include(@cancelled)
          expect(TeaTime.na).to include(@tt, @past_tt)
        end
      end

      describe '#cancelled' do
        it 'should only include tea times with cancelled status' do
          expect(TeaTime.cancelled).to include(@cancelled)
          expect(TeaTime.cancelled).not_to include(@tt, @past_tt)
        end
      end
    end
  end

  describe '.attendees' do
    before(:all) do
      @tea_time = create(:tt_with_attendees)
      @att_flake = create(:attendance, :flake, tea_time: @tea_time)
    end

    it 'should return the User objects of attendees' do
      expect(@tea_time.attendees.count).to eq(4)
    end

    it 'should remove items matching the given filter proc' do
      expect(@tea_time.attendees(filter: ->(a) { a.flake? })).not_to include(@att_flake.user)
    end 

    describe '.all_attendee_emails' do
      it 'should concatenate email addresses of attendees' do
        tea_time = TeaTime.new
        tea_time.stub(attendees: [
          mock_model('User', email: 'foo@tws.com', status: 'pending'),
          mock_model('User', email: 'bar@tws.com', status: 'pending'),
          mock_model('User', email: 'baz@tws.com', status: 'pending'),
        ])
        expect(tea_time.all_attendee_emails).to eq('foo@tws.com,bar@tws.com,baz@tws.com')
      end

      it 'should exclude items matching a given filter' do
        expect(@tea_time.all_attendee_emails(filter: :flake?)).not_to include(@att_flake.user.email)
      end
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

  describe 'permissions' do
    it 'should let admins edit any tea time' do
      u = create(:user, :admin)
      a = Ability.new(u)
      tt = create(:tea_time)
      
      a.should be_able_to(:edit, tt)
    end

    it 'should let hosts edit only their own tea times' do
      u = create(:user, :host)
      u2 = create(:user, :host)
      a = Ability.new(u)
      a2 = Ability.new(u2)
      tt = create(:tea_time, host: u)
      
      a.should be_able_to(:edit, tt)
      a2.should_not be_able_to(:edit, tt)
    end
  end
end
