require 'spec_helper'

describe User do
  it { expect(subject).to validate_presence_of(:name) }
  it { expect(subject).to validate_presence_of(:home_city_id) }

  context 'roles' do
    let(:admin) { create(:user, :admin) }
    let(:host) { create(:user, :host) }
    let(:user) { create(:user) }

    describe '.admin?' do
      it 'should return false for non-admins' do
        expect(host.admin?).to eq(false)
        expect(user.admin?).to eq(false)
      end

      it 'should return true for an admin' do
        expect(admin.admin?).to eq(true)
      end
    end

    describe '.host?' do
      it 'should return true for an admin' do
        expect(admin.host?).to eq(true)
      end

      it 'should return true for an host' do
        expect(host.host?).to eq(true)
      end
    end
  end

  describe 'facebook' do
    it 'should be able to store a string as a facebook' do
      user = FactoryGirl.create(:user, facebook: 'hoo')
      expect(user.facebook).to eq 'hoo'
      expect(user.id).to_not be_nil
    end

    it 'should not include the http' do
      user = User.create(facebook: 'http://foo')
      expect(user.errors.messages[:facebook]).to include "should not include http(s)"
    end

    it 'should not include https' do
      user = User.create(facebook: 'https://foo')
      expect(user.errors.messages[:facebook]).to include "should not include http(s)"
    end

    it 'should not include facebook.com' do
      user = User.create(facebook: 'www.facebook.com')
      expect(user.errors.messages[:facebook]).to include "should not include facebook.com"
    end
  end

  describe '#facebook_url' do
    it 'prefixes facebook id with schema' do
      facebook_id = 'foobarbaz'
      user = User.new(facebook: facebook_id)
      expect(user.facebook_url).to eq "https://facebook.com/#{facebook_id}"
    end
    it 'returns nil if user does not have a facebook id' do
      user = User.new(facebook: nil)
      expect(user.facebook_url).to eq nil
    end
  end

  describe '#twitter_url' do
    it 'prefixes twitter handle with schema' do
      handle = "twstrangers"
      user = User.new(twitter: handle)
      expect(user.twitter_url).to eq "https://twitter.com/#{handle}"
    end
    it 'returns nil if user does not have a twitter handle' do
      user = User.new(twitter: nil)
      expect(user.twitter_url).to eq nil
    end
  end

  describe 'twitter' do
    it 'should be able to store a string as a twitter handle' do
      user = User.new(twitter: 'blablah')
      expect(user.twitter).to eq 'blablah'
    end

    it 'should not contain special characters' do
      user = User.create(twitter: '@asda!^7')
      expect(user.errors.messages[:twitter]).to include 'not a valid twitter handle'
    end
  end

  describe '.flake_future' do
    let(:tt) { create(:tea_time, attendee_count: 1) }
    let(:user) { tt.attendances.first.user }
    let(:past_att) {
      past_tt = create(:tea_time, :past)
      create(:attendance, tea_time: past_tt, user: user)
    }


    it 'should flake all future attendances' do
      user.flake_future
      expect(user.attendances.first.flake?).to eq(true)
    end

    it 'should ignore past attendances' do
      user.flake_future
      expect(past_att.status).not_to eq(:flake)
    end
  end
end
