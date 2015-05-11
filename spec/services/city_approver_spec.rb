require 'spec_helper'

describe CityApprover do
  let(:non_existent_city_id) do
    5000
  end

  let(:unapproved_city) do
    create(:city, brew_status: "unapproved", suggested_by_user: create(:user))
  end

  describe "#initialize" do
    context 'Invalid city_id is provided' do
      it 'raises an error' do
         
        expect { described_class.new(non_existent_city_id) }.to raise_error
      end
    end
  end

  describe '#approve!' do
    context 'Valid city_id is provided' do
      context 'City is in unapproved state' do
        it 'should put the city in cold_brew state' do
          subject = described_class.new(unapproved_city.id)
          subject.approve!
          unapproved_city.reload
          expect(unapproved_city.brew_status).to eq "cold_water"
        end

        it 'sends an email to the suggested_by_user' do
          subject = described_class.new(unapproved_city.id)
          mock_mailer = double('Mail::Message')
          expect(UserMailer).to receive(:notify_city_suggestor).
            with(unapproved_city, :approved).
            and_return(mock_mailer)
          expect(mock_mailer).to receive(:deliver)
          subject.approve!
        end
      end

      context 'City is not in unapproved state' do
        City.brew_statuses.each do |key, value|
          next if key == "unapproved"
          it "raises an error if status is #{key}" do
            non_unapproved_city = create(:city, brew_status: key)
            subject = described_class.new(non_unapproved_city.id)
            expect { subject.approve! }.to raise_error(CityApprover::CityApprovedError)
          end

          it 'does not change the brew_status' do
            non_unapproved_city = create(:city, brew_status: key)
            subject = described_class.new(non_unapproved_city.id)
            begin
              subject.approve!
            rescue CityApprover::CityApprovedError
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
