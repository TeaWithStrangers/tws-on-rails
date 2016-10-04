class RefreshHostActivityStatus
  ACTIVE_EXPIRATION = 30.days
  MILD_LEGACY = {
    :tea_time_max => 5,
    :expiration => 2.months,
  }
  STRONG_LEGACY = {
    :tea_time_max => 10,
    :expiration => 3.months,
  }

  def self.run
    User.hosts.each do |user|
      host_detail = user.host_detail
      # update or create a host_detail for the host
      new_status = find_new_status(user)
      if host_detail
        if new_status != host_detail.activity_status
          host_detail.update(:activity_status => new_status)
        end
      else
        detail = user.build_host_detail(:activity_status => new_status)
        detail.save!
      end
    end
  end

  def self.find_new_status(user)
    tea_times = user.tea_times.order('start_time asc').to_a
    if tea_times.empty?
      # INACTIVE
      new_status = HostDetail::ACTIVITY_STATUS_INACTIVE
    elsif tea_times.last.start_time > (Time.now - ACTIVE_EXPIRATION)
      # ACTIVE
      new_status = HostDetail::ACTIVITY_STATUS_ACTIVE
    else
      if legacy_expired?(MILD_LEGACY, tea_times) || legacy_expired?(STRONG_LEGACY, tea_times)
        # INACTIVE (legacy expired)
        new_status = HostDetail::ACTIVITY_STATUS_INACTIVE
      else
        # LEGACY
        new_status = HostDetail::ACTIVITY_STATUS_LEGACY
      end
    end
  end

  def self.legacy_expired?(legacy_type, tea_times)
    expiration_cutoff = Time.now - ACTIVE_EXPIRATION - legacy_type[:expiration]
    tea_times.count <= legacy_type[:tea_time_max] &&
      tea_times.last.start_time < expiration_cutoff
  end
end