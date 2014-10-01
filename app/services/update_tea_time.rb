class UpdateTeaTime
  class << self
    def call(tea_time, update)
      old_host = tea_time.host
      host_change = host_changed?(tea_time, update)
      update = tea_time.update(update)

      if update && host_change
        TeaTimeMailer.delay.host_changed(tea_time.id, old_host.id)
      end

      return update
    end

    def host_changed?(tea_time, update)
      update[:user_id] && tea_time.host != User.find(update[:user_id])
    end
  end
end
