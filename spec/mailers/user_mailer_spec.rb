require 'spec_helper'

describe UserMailer do
  describe '#registration' do
    let(:user) { create(:user, :unconfirmed) }

    let(:token) { Devise.token_generator.digest(User, :confirmation_token, "fake") }
    let(:mail) { UserMailer.registration(user, token) }

    it 'should include the confirmation link' do
      expect(mail.parts.first.to_s).to include(token)

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
end
