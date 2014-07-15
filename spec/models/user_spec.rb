require 'spec_helper'

describe 'User' do
  it 'is not valid without a home city' do
    user = User.create
    expect(user.errors.messages.keys).to include :home_city_id
    expect(user.errors.messages[:home_city_id]).to include "can't be blank"
  end

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
      user = User.create(facebook: 'foo')
      expect(user.facebook).to eq 'foo'
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
end