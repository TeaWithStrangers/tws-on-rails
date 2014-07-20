require 'spec_helper'

describe AttendanceMailer do
  before(:all) do
    @tt = create(:tea_time)
    @attendance = create(:attendance, tea_time: @tt)
  end

  describe '.reminder' do
    context 'flaked attendees' do
      it "shouldn't be sent a reminder" do
        @attendance.flake!
        AttendanceMailer.reminder(@attendance.id, :same_day).deliver
        #Flake mails get created, reminder shouldn't be
        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end
    end
    
    let(:mail) {
      AttendanceMailer.reminder(@attendance.id, :same_day)
    }

    it 'should come from the host' do
      expect(mail.from).to eq([@tt.host.email])
    end

    it 'should be sent to attendee' do
      expect(mail.to).to eq([@attendance.user.email])
    end

    it 'should contain tea time and host info' do
      expect(mail.body.encoded).to match(@tt.friendly_time)
      expect(mail.body.encoded).to match(@tt.host.name)
    end
  end

  describe '.flake' do
    it 'should be sent when .flake! is called' do
      @attendance.flake!
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end
end
