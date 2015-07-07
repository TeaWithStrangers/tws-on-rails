module Delayed
  class PerformableMailer < PerformableMethod
    alias_method :perform_original, :perform
    def perform
      begin
        perform_original
      rescue DeliveryCancellationException
        logger.error "Cancelled delivery due to cancel_delivery"
      rescue Errno::ECONNREFUSED
        logger.error "Failed to send email in #{Rails.env}"
      end
    end
  end
end
