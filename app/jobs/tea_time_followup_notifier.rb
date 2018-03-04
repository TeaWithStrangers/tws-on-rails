class TeaTimeFollowupNotifier
  def initialize(tea_time_id)
    @tea_time_id = tea_time_id
  end

  def perform
    tt = TeaTime.find(@tea_time_id)
    if !tt.cancelled? #Abort Followup if TT didn't happen
      groups = tt.attendances.group_by(&:status)

      groups.each do |status, attendances|
        TeaTimeMailer.followup(@tea_time_id, attendances, status).deliver_now
      end
    end
  end
end
