require 'spec_helper.rb'

describe TeaTime do
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