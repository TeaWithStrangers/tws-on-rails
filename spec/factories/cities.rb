FactoryGirl.define do
  factory :city do
    sequence(:name) {|n| "City #{n}" }
    sequence(:city_code) {|n| "city-#{n}" }
    brew_status "fully_brewed"
    timezone "Pacific Time (US & Canada)"
    tagline "Tagline"
    description "Something bueler bueler bueler lorem"

    City.brew_statuses.each do |k,v|
      trait k.to_sym do
        brew_status k
      end
    end
  end
end
