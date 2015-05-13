require 'spec_helper'

describe CityCodeGenerator do
  describe '#generate' do
    it 'returns a string' do
      expect(described_class.generate.class).to eq String
    end
  end
end