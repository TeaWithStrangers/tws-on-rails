require 'spec_helper'

describe AttendanceMailer do
  let(:tt) { create(:tea_time) }
  let(:attendance) { create(:attendance, tea_time: tt) }

  describe '#registration' do
    let(:mail) {
      AttendanceMailer.registration(attendance.id)
    }

    it "should include the user's name in the subject" do
      expect(mail.subject).to include(attendance.user.name)
    end

    it 'should include an event attachment' do
      expect(mail.attachments['event.ics']).not_to eq(nil)
      expect(mail.attachments['event.ics'].content_type).to eq("text/calendar")
    end

    it 'should be addressed to the attendee' do
      expect(mail.body.to_s).to include(attendance.user.name)
    end
  end

  context 'Waiting List Mails:' do
    let!(:wl_attendances) { create_list(:attendance, 3, tea_time: tt, status: :waiting_list) }
    describe '#waitilist_free_spot' do
      let(:mail) { AttendanceMailer.waitlist_free_spot(tt.id) }

      it 'should be sent to all wait list attendees but no one else' do
        wl_attendances.map(&:user).map(&:email).each do |email|
          expect(mail.bcc.sort).to include(email)
        end
      end
    end

    describe '#waitlist' do
      let(:attendance) { wl_attendances.sample }
      let(:mail) { AttendanceMailer.waitlist(attendance.id) }

      it 'should include the host name' do
        expect(mail.body.parts.first.to_s).to include(tt.host.name)
      end
    end
  end

  describe '#reminder' do
    context 'flaked attendees' do
      it "shouldn't be sent a reminder" do
        attendance.update_column(:status, 1)
        AttendanceMailer.reminder(attendance.id, :same_day).deliver
        #Flake mails get created, reminder shouldn't be
        expect(ActionMailer::Base.deliveries.size).to eq(0)
      end
    end

    let(:mail) {
      AttendanceMailer.reminder(attendance.id, :same_day)
    }

    it 'should come from the default email' do
       default_from = Mail::Address.new(AttendanceMailer.default[:from]).address
      expect(mail.from).to eq([default_from])
    end

    it 'should be sent to attendee' do
      expect(mail.to).to eq([attendance.user.email])
    end

    it 'should contain tea time and host info' do
      expect(mail.body.encoded).to match(tt.friendly_time)
      expect(mail.body.encoded).to match(tt.host.name)
    end
  end

  #TODO: This is really a test of .flake! not the message itself. Move to
  #attendance_spec when possible
  describe '#flake' do
    it 'should be sent when .flake! is called' do
      attendance.flake!
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end
end
