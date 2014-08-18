require 'spec_helper'

describe MassMailer do
  describe '.simple_mail' do
    let(:defaults) {{
      city_id: @user.home_city.id,
      subject: 'Test',
      body: "*Testing* **italics** and [links](#{root_path})" 
    }}

    let(:mail) { MassMailer.simple_mail(defaults) }

    before(:all) do
      @user = create(:user)
      @user_in_different_city = create(:user)
    end

    it 'should set the subject' do
      expect(mail.subject).to eq(defaults[:subject])
    end

    it 'should only send to users in the selected city' do
      expect(sendgrid_headers(mail)['to']).to eq [@user.email]
    end

    it 'should use default parameters if not submitted' do
      expect(mail.from).to eq mail.to
    end

    it 'should use given parameters if submitted' do
      params = defaults.merge({to: 'barf@eagle5.io'})
      mail = MassMailer.simple_mail(params)
      expect(mail.to).not_to eq mail.from
    end
  end
end

private 
def sendgrid_headers(mail)
  JSON.parse(mail['X-SMTPAPI'].value)
end
