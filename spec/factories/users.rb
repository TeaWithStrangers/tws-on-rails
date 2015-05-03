FactoryGirl.define do

  factory :user do
    nickname "Joe"
    given_name "Joseph"
    family_name "Doe"
    sequence(:email) { |n| "dummy#{n}@teawithstrangers.com" }
    password "password"
    association :home_city, factory: :city

    [:host, :admin].each do |t| #YOLO
      trait t do
        nickname "Joe #{t.capitalize}"
        family_name "#{t.capitalize}"

        after :build do |u|
          u.roles << t
        end
      end
    end
  end
end
