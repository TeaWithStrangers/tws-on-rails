class AttendanceReminderJob
  attr_reader :tea_time
  def initialize(tea_time)
    @tea_time = tea_time
  end

  def mark_attendance_reminder(attendance_id)
    tea_time.reload

    if Time.now >= mark_attendance_reminder_time && !tea_time.deleted?
      AttendanceMailer.mark_attendance_reminder(attendance_id)
    end
  end

  handle_asynchronously :mark_attendance_reminder,
    :run_at => Proc.new { |job| job.mark_attendance_reminder_time }

  def mark_attendance_reminder_time
    tea_time.end_time + 30.minutes
  end

  def two_day_reminder(attendance_id)
    tea_time.reload
    if Time.now >= two_day_reminder_time && !tea_time.deleted?
      AttendanceMailer.reminder(attendance_id, :two_day)
    end
  end

  handle_asynchronously :two_day_reminder,
    :run_at => Proc.new { |job| job.two_day_reminder_time }

  def two_day_reminder_time
    tea_time.start_time - 2.days
  end

  def twelve_hour_reminder
    if Time.now >= twelve_hour_reminder_time
      AttendanceMailer.reminder(self.id, :same_day)
    end
  end

  handle_asynchronously :twelve_hour_reminder,
    :run_at => Proc.new { |job| job.twelve_hour_reminder_time }

  def twelve_hour_reminder_time
    tea_time.start_time - 12.hours
  end
end
