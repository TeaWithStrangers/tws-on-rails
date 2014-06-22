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
end
