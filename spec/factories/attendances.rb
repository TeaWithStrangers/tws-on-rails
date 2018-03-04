FactoryBot.define do
  factory :attendance do
    tea_time
    user_id { FactoryBot.create(:user).id }
    status :pending
  end

  trait :present do
    status :present
  end

  trait :flake do
    status :flake
  end

  trait :waitlist do
    status :waiting_list
  end

  trait :no_show do
    status :no_show
  end
end
