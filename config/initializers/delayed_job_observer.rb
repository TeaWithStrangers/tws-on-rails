# Thanks to @dblock and @artsy!

class DelayedJobObserver < ActiveRecord::Observer
  observe Delayed::Job

  class << self
    attr_accessor :total_processed
    attr_accessor :total_errors
    attr_accessor :enabled

    def enabled?
      !! DelayedJobObserver.enabled
    end

    def enable!
      DelayedJobObserver.enabled = true
    end

    def disable!
      DelayedJobObserver.enabled = false
    end

    def reset!
      DelayedJobObserver.total_processed = 0
      DelayedJobObserver.total_errors = 0
      DelayedJobObserver.enable!
    end
  end

  def after_create(delayed_job)
    begin
      delayed_job.invoke_job if DelayedJobObserver.enabled?
    rescue
      DelayedJobObserver.total_errors += 1
    end
    DelayedJobObserver.total_processed += 1
  end
end

DelayedJobObserver.reset!
