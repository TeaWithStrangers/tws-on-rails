FactoryGirl.define do
  factory :host_detail, class: 'HostDetail' do
    association :user, factory: [:user, :host]
    activity_status 0
    commitment 0

    trait :inactive do
    end

    trait :active do
      activity_status 1
    end

    trait :legacy do
      activity_status 2
    end
  end
end
