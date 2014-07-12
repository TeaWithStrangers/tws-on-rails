FactoryGirl.define do
  factory :attendance do
    tea_time
    user_id { FactoryGirl.create(:user).id }
    status :pending
  end

  trait :flake do
    status :flake
  end
end
