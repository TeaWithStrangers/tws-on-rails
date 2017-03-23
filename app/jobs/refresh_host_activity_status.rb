class RefreshHostActivityStatus
  ACTIVE_EXPIRATION = 4.weeks
  LEGACY_EXPIRATION = 6.months
  PROLIFIC_HOST_CUTOFF = 15

  def self.run
    User.includes(:host_detail).hosts.select(:id).find_each do |user|

      # update or create a host_detail for the host
      user.build_host_detail unless user.host_detail

      host_detail = user.host_detail
      new_status = find_new_status(user)

      if new_status != host_detail.activity_status
        host_detail.update(:activity_status => new_status)
      end
    end
  end

  def self.find_new_status(user)
    tea_times = user.tea_times.completed.order('start_time asc').to_a
    most_recent = tea_times.last
    user.send_drip_email(most_recent)
    commitment = user.commitment
    if user.tea_times.future.pending.any?
      new_status = :active
    elsif tea_times.empty? || commitment == HostDetail::INACTIVE_COMMITMENT
      # they have never hosted or told us they are inactive
      new_status = :inactive
    elsif tea_times.last.start_time > (Time.now - ACTIVE_EXPIRATION)
      # hosted recently or have upcoming tea times
      new_status = :active
    elsif most_recent.start_time < Time.now - LEGACY_EXPIRATION && tea_times.count < PROLIFIC_HOST_CUTOFF
      # they've dropped off of legacy status into expired
      new_status = :inactive
    else
      # temporarily inactive
      new_status = :legacy
    end
  end
end