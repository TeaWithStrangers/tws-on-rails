module ProfilesHelper
  def display_button?(assigns)
    (assigns.key?(:without_button) && assigns[:without_button] == false) ? false : true
  end

  def humanize_attendance_status(status)
    case status
    when 'pending'
      'attendee'
    when 'flake'
      'canceled'
    when 'cancelled'
      'canceled on'
    else
      status
    end
  end
end
