FactoryGirl.define do
  factory :tea_time do
    city
    association :host, factory: [:user, :host]
    start_time DateTime.now.midnight + 2.days + 12.hours
    duration 2
    transient {
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
      transient { attendee_count 3 }
    end

    trait :was_attended do
      transient { present_count 3 }
    end

    trait :attended_flakes do
      transient {
        attendee_count 3
        flake_count 2
      }
    end

    trait :full do
      transient { attendee_count 5 }
    end

    trait :full_waitlist do
      full
      transient {
        waitlist_count 2
      }
    end

    trait :empty_waitlist do
      transient {
        waitlist_count 2
      }
    end

    trait :mixed do
      past
      was_attended

      transient {
        flake_count 2
        waitlist_count 1
        no_show_count 1
      }
    end

    #Skip validation on create so past TTs can be generated
    to_create {|instance| instance.save(validate: false) }

    after(:create) do |tt, evaluator|
      create_list(:attendance, evaluator.attendee_count, tea_time: tt)
      create_list(:attendance, evaluator.present_count, :present, tea_time: tt)
      create_list(:attendance, evaluator.flake_count, :flake, tea_time: tt)
      create_list(:attendance, evaluator.waitlist_count, :waitlist, tea_time: tt)
      create_list(:attendance, evaluator.no_show_count, :no_show, tea_time: tt)
    end
  end
end
