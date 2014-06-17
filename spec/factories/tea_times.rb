FactoryGirl.define do
  factory :tea_time do
    city 
    association :host, factory: [:user, :host]
    start_time DateTime.now.midnight + 2.days + 12.hours
    duration 2

    trait :past do
      start_time DateTime.now.midnight - 2.days
    end

    trait :cancelled do
      followup_status :cancelled
    end

    factory :tt_with_attendees do
      ignore do
        attendee_count 3
      end

      trait :full do
        ignore do
          attendee_count 5
        end
      end

      after(:create) do |tt, evaluator|
        create_list(:attendance, evaluator.attendee_count, tea_time: tt)
      end
    end
  end
end
