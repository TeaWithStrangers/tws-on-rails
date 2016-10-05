require 'spec_helper'

describe UserMailer do

  describe 'confirm_city_suggestion' do
    let(:mock_user) do
      user = double('User', email: 'foo@goo.com', nickname: "Anthony Gonsalves")
      allow(user).to receive(:name).and_return(user.nickname)
      user
    end
    let(:mock_city) do
      double('City', id: 5, suggested_by_user: mock_user, name: "Wonderland")
    end
    before(:each) do
      allow(City).to receive(:find).with(5).and_return(mock_city)
    end

    it 'should be sent to suggestor' do
      mail = UserMailer.confirm_city_suggestion(mock_city.id)
      expect(mail.to).to eq([mock_user.email])
    end
    it 'should contain the name of the city' do
      mail = UserMailer.confirm_city_suggestion(mock_city.id)
      expect(mail.parts.first.to_s).to include(mock_city.name)
    end
    it 'should contain the suggestor nickname' do
      mail = UserMailer.confirm_city_suggestion(mock_city.id)
      expect(mail.parts.first.to_s).to include(mock_user.nickname)
    end
    it 'should have a subject' do
      mail = UserMailer.confirm_city_suggestion(mock_city.id)
      expect(mail.subject).to eq "We got your suggestion for Tea With Strangers in #{mock_city.name}"
    end

    it 'should have a line break in sign off' do
      mail = UserMailer.confirm_city_suggestion(mock_city.id)
      expect(mail.html_part.to_s).to include("Bleep bleep bloop,<br>")
    end
  end

  describe '#notify_city_suggestor' do
    let(:mock_user) do
      user = double('User', email: 'foo@goo.com', nickname: "Anthony Gonsalves")
      allow(user).to receive(:name).and_return(user.nickname)
      user
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
      allow(City).to receive(:find).with(100).and_raise(ActiveRecord::RecordNotFound)
    end

    it 'should not send email if there is no suggestor' do
      mail = described_class.notify_city_suggestor(6, :approved)
      expect(mail).to eq NullMessage
    end

    it 'should send email to the suggestor' do
      mail = described_class.notify_city_suggestor(5, :approved)
      expect(mail.to).to include mock_user.email
    end

    it 'should raise an error if the city is not found' do
      expect { described_class.notify_city_suggestor(100, :approved) }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'should have a line break in sign off' do
      mail = described_class.notify_city_suggestor(mock_city.id, :approved)
      expect(mail.html_part.to_s).to include("Bleep bleep bloop,<br>")
    end

    context 'merged' do
      it 'should have a link to the city page' do
        mail = described_class.notify_city_suggestor(mock_city.id, :merged)
        expect(mail.html_part.to_s).to include("#{city_url(mock_city.id)}")
      end
    end

    context 'approved' do
      it 'should have a link to the city page' do
        mail = described_class.notify_city_suggestor(mock_city.id, :approved)
        expect(mail.html_part.to_s).to include("#{city_url(mock_city.id)}")
      end
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
