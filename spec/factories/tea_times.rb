FactoryGirl.define do
  factory :tea_time do
    city
    association :host, factory: [:user, :host]
    start_time DateTime.now.midnight + 2.days + 12.hours
    duration 2
    ignore {
      present_count 0
      attendee_count 0
      waitlist_count 0
      flake_count 0
      no_show_count 0
    }

    trait :past do
      start_time DateTime.now.midnight - 2.days
    end

    trait :cancelled do
      followup_status :cancelled
    end

    trait :attended do
      ignore { attendee_count 3 }
    end

    trait :was_attended do
      ignore { present_count 3 }
    end

    trait :attended_flakes do
      ignore {
        attendee_count 3
        flake_count 2
      }
    end

    trait :full do
      ignore { attendee_count 5 }
    end

    trait :full_waitlist do
      full
      ignore {
        waitlist_count 2
      }
    end

    trait :empty_waitlist do
      ignore {
        waitlist_count 2
      }
    end

    trait :mixed do
      past
      was_attended

      ignore {
        flake_count 2
        waitlist_count 1
        no_show_count 1
      }
    end

    after(:create) do |tt, evaluator|
      create_list(:attendance, evaluator.attendee_count, tea_time: tt)
      create_list(:attendance, evaluator.present_count, :present, tea_time: tt)
      create_list(:attendance, evaluator.flake_count, :flake, tea_time: tt)
      create_list(:attendance, evaluator.waitlist_count, :waitlist, tea_time: tt)
      create_list(:attendance, evaluator.no_show_count, :no_show, tea_time: tt)
    end
  end
end
