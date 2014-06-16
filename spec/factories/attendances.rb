FactoryGirl.define do
  factory :attendance do
    tea_time
    user
    status :pending
  end

  trait :flake do
    status :flake
  end
end
