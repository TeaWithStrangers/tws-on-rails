require 'spec_helper'

describe AdminController do
  before do
    [:authenticate_user!, :authorized?].each do |s|
      controller.stub(s) {
        true
      }
    end
  end

  describe '#send_mail' do
    let(:mail) {{
      city_id: create(:city).id,
      subject: 'Test',
      body: 'Test'
    }}

    it 'should reject invalid mails' do
      mail[:subject] = nil
      post :send_mail, admin_controller_mass_mail: mail
      expect(request.flash[:alert]).not_to eq(nil)
    end

    it 'should send valid mails' do
      post :send_mail, admin_controller_mass_mail: mail
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
