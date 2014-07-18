module Delayed
  class PerformableMailer < PerformableMethod
    alias_method :perform_original, :perform
    def perform
      begin
        perform_original
      rescue DeliveryCancellationException
        logger.info "Cancelled delivery due to cancel_delivery"
      end
    end
  end
end
