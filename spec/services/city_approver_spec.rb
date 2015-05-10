require 'spec_helper'

describe CityApprover do
  let(:non_existent_city_id) do
    5000
  end

  let(:unapproved_city) do
    create(:city, brew_status: "unapproved")
  end

  describe '#call' do
    context 'Invalid city_id is provided' do
      it 'raises an error' do
        subject = described_class.new(non_existent_city_id)
        expect { subject.call }.to raise_error
      end
    end

    context 'Valid city_id is provided' do
      context 'City is in unapproved state' do
        it 'should put the city in cold_brew state' do
          subject = described_class.new(unapproved_city.id)
          subject.call
          unapproved_city.reload
          expect(unapproved_city.brew_status).to eq "cold_water"
        end
      end

      context 'City is not in unapproved state' do
        City.brew_statuses.each do |key, value|
          next if key == "unapproved"
          it "raises an error if status is #{key}" do
            non_unapproved_city = create(:city, brew_status: key)
            subject = described_class.new(non_unapproved_city.id)
            expect { subject.call }.to raise_error("City must be in unapproved state to run this")
          end

          it 'does not change the brew_status' do
            non_unapproved_city = create(:city, brew_status: key)
            subject = described_class.new(non_unapproved_city.id)
            begin
              subject.call
            rescue RuntimeError
            ensure
              non_unapproved_city.reload
              expect(non_unapproved_city.brew_status).to eq key
            end
          end
        end
      end
    end
  end
end