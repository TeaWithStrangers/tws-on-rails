class CancelTeaTime
  def self.call(tea_time)
    if tea_time.cancel!
      send_cancellations(tea_time)
      true
    else
      false
    end
  end

  def self.send_cancellations(tea_time)
    tea_time.attendances.each do |att|
      TeaTimeMailer.delay.cancellation(tea_time.id, att.id)
    end
  end
end
