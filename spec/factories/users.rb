FactoryGirl.define do

  factory :user do
    name "Joe User"
    sequence(:email) { |n| "dummy#{n}@teawithstrangers.com" }
    password "password"
    association :home_city, factory: :city

    [:host, :admin].each do |t| #YOLO
      trait t do
        name "Joe #{t.capitalize}"

        after :build do |u|
          u.roles << Role.find_by(name: t.capitalize)
        end
      end
    end
  end
end
