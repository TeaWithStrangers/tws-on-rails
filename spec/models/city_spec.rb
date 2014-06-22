require 'spec_helper.rb'

describe City do
  context 'scopes' do
    before(:each) do
      @city = create(:city, :fully_brewed)
      @warm = create(:city, :warming_up)
      @hidden = create(:city, :hidden)
    end

    describe '#default_scope' do
      it 'should exclude hidden locations' do
        expect(City.all).to include(@city, @warm)
        expect(City.all).not_to include(@hidden)
      end

      it 'should include hidden locations when unscoped' do
        expect(City.unscoped.all).to include(@city, @warm, @hidden)
      end
    end

    describe '#hidden' do
      it 'should only include hidden locations' do
        expect(City.hidden).to include(@hidden)
        expect(City.hidden).not_to include(@city, @warm)
      end
    end
  end

  describe '.proxy_city=' do
    it 'should not be able to save if self is proxy target' do
      city = create(:city)

      city.proxy_city = city
      expect(city.save).to eq(false)
      expect{ city.save! }.to raise_exception
    end
  end


  describe '.tea_times' do
    before(:each) do
      @second_city = create(:city)
      create_list(:tea_time, 3, city: @second_city)
      @city = create(:city, proxy_city: @second_city)
      @tt = create(:tea_time, city: @city)
    end

    it 'should include tea times associated for that city' do
      expect(@city.tea_times).to include(@tt)
    end

    it 'should include tea times associated for that city AND the proxy city if specified' do
      expect(@city.tea_times).to include(*@second_city.tea_times, @tt)
    end
  end
end
