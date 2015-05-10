require 'spec_helper'

describe UserMailer do
  describe '#notify_city_suggestor_of_approval' do
    let(:mock_user) do
      double('User', email: 'foo@goo.com', nickname: "Anthony Gonsalves")
    end
    let(:mock_city) do
      double('City', id: 5, suggested_by_user: mock_user, name: "Wonderland")
    end
    let(:city_without_suggestor) do
      double('City', id: 6, suggested_by_user: nil, name: "Wonderland")
    end
    before(:each) do
      allow(City).to receive(:find).with(5).and_return(mock_city)
      allow(City).to receive(:find).with(6).and_return(city_without_suggestor)
      allow(City).to receive(:find_by).with({id: 5}).and_return(mock_city)
      allow(City).to receive(:find_by).with({id: 6}).and_return(city_without_suggestor)
      allow(City).to receive(:find_by).with({id: 100}).and_return(nil)
    end

    it 'should not send email if there is no suggestor' do
      mail = described_class.notify_city_suggestor_of_approval(6)
      expect(mail.class).to eq ActionMailer::Base::NullMail
    end

    it 'should send email to the suggestor' do
      mail = described_class.notify_city_suggestor_of_approval(5)
      expect(mail.to).to include mock_user.email
    end

    it 'should be from teawithstrangers' do
      mail = described_class.notify_city_suggestor_of_approval(5)
      expect(mail.from).to include "sayhi@teawithstrangers.com"
    end
    it 'should not send if the city is not found' do
      mail = described_class.notify_city_suggestor_of_approval(100)
      expect(mail.class).to eq ActionMailer::Base::NullMail
    end
  end

  describe '#registration' do
    let(:user) { create(:user) }
    let(:password) { "passwordQuazBux" }
    let(:mail) { UserMailer.registration(user, password) }

    it 'should include the password' do
      expect(mail.parts.first.to_s).to include(password)
    end

    it 'should send the coming soon mail if a user\'s city has no tea times' do
      expect(user.home_city.tea_times).to eq []
      expect(mail.parts.first.to_s).to match "We aren't fully set up"
    end

    it 'should send the register for TT intro if a user\'s city has tea times' do
      create(:tea_time, city: user.home_city)
      expect(mail.parts.first.to_s).to match "happening pretty regularly"
    end
  end
end
