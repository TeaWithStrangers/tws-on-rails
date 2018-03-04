FactoryBot.define do

  factory :user do
    nickname "Joe"
    given_name "Joseph"
    family_name "Doe"
    sequence(:email) { |n| "dummy#{n}@teawithstrangers.com" }
    password "password"
    association :home_city, factory: :city

    trait :waitlist do
      waitlisted true
      waitlisted_at Time.now
    end

    [:host, :admin].each do |t| #YOLO
      trait t do
        nickname "Joe #{t.capitalize}"
        family_name "#{t.capitalize}"

        after :create do |u|
          FactoryBot.create(:host_detail, :user => u)
        end

        after :build do |u|
          u.roles << t
        end
      end
    end
  end
end
