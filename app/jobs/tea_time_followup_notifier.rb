class TeaTimeFollowupNotifier
  def initialize(tea_time_id)
    @tea_time_id = tea_time_id
  end

  def perform
    tt = TeaTime.find(@tea_time_id)
    if !tt.cancelled? #Abort Followup if TT didn't happen
      groups = tt.attendances.group_by(&:status)

      groups.each do |status, attendees|
        TeaTimeMailer.followup(@tea_time_id, attendees, status).deliver
      end
    end
  end
end
