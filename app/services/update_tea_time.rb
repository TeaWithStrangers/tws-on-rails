class UpdateTeaTime
  class << self
    def call(tea_time, update)
      old_host = tea_time.host
      old_start_time = tea_time.start_time
      old_end_time = tea_time.end_time
      host_change = host_changed?(tea_time, update)
      update = tea_time.update(update)

      if update
        if host_change
          TeaTimeMailer.delay.host_changed(tea_time.id, old_host.id)
        end

        if old_start_time != tea_time.start_time
          tea_time.attendances.each(&:queue_reminders)
        end

        if old_end_time != tea_time.end_time
          tea_time.queue_attendance_reminder
        end
      end

      update
    end

    def host_changed?(tea_time, update)
      update[:user_id] && tea_time.host != User.find(update[:user_id])
    end
  end
end
