require 'spec_helper.rb'

describe City do
  it { expect(subject).to belong_to(:suggested_by_user).class_name('User') }

  context 'scopes' do
    before(:all) do
      @city = create(:city, :fully_brewed)
      @warm = create(:city, :warming_up)
      @hidden = create(:city, :hidden)
    end

    describe '#default_scope' do
      it 'should include hidden locations' do
        expect(City.all).to include(@city, @warm, @hidden)
      end
    end

    describe '#visible' do
      it 'should not include hidden locations' do
        expect(City.visible).to include(@city, @warm)
        expect(City.visible).not_to include(@hidden)
      end

      it 'should not include hidden cities for normal users' do
        user = create(:user)
        expect(City.visible(user)).to include(@city, @warm)
        expect(City.visible).not_to include(@hidden)
      end

      it 'should include hidden cities if a user can permissions' do
        host = create(:user, :host)
        expect(City.visible(host)).to include(@city, @warm, @hidden)
      end
    end

    describe '#hidden' do
      it 'should only include hidden locations' do
        expect(City.hidden).to include(@hidden)
        expect(City.hidden).not_to include(@city, @warm)
      end
    end
  end

  describe '#for_code' do
    it 'should find a city regardless of status' do
      city = create(:city, :hidden, city_code: 'hidden')
      expect(City.for_code('hidden')).to eq(city)
    end

    it 'should find a city by primary key as a fallback' do
      city = create(:city, city_code: 'hidden')
      expect(City.for_code(city.id.to_s)).to eq(city)
    end
  end

  describe '.proxy_city=' do
    it 'should not be able to save if self is proxy target' do
      city = create(:city)

      city.proxy_cities << city
      expect(city.save).to eq(false)
      expect{ city.save! }.to raise_exception
    end
  end


  context 'proxy_cities' do
    before(:all) do
      @second_city = create(:city)
      @third_city = create(:city)
      create_list(:tea_time, 3, city: @second_city)
      create_list(:tea_time, 3, city: @third_city)
      @city = create(:city, proxy_cities: [@second_city, @third_city])
      @tt = create(:tea_time, city: @city)
      @tt_3rd = create(:tea_time, city: @third_city)
    end

    describe '.hosts' do
      it 'should include hosts for that city' do
        host = create(:user, :host, home_city: @city)
        expect(@city.hosts).to include(host)
    end

    it 'should include hosts for proxy cities' do
      expect(@city.hosts).to include(*@second_city.hosts, *@third_city.hosts)
    end
  end

    describe '.tea_times' do
      it 'should include tea times associated for that city' do
        expect(@city.tea_times).to include(@tt)
      end

      it 'should include tea times associated for that city AND the proxy cities if specified' do
        expect(@city.tea_times).to include(*@second_city.tea_times, @tt, *@third_city.tea_times)
      end
    end
  end
end
