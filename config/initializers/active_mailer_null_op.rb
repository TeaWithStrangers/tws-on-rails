class NullMessage < Mail::Message
  def self.deliver
    false
  end

  def self.deliver_later
    false
  end

  def self.deliver_now
    false
  end
end

ActionMailer::Base.class_eval do
  alias_method :process_original, :process

  class DeliveryCancellationException < StandardError; end;

  def cancel_delivery
    raise DeliveryCancellationException
  end

  def process(*args)
    begin
      process_original *args
    rescue DeliveryCancellationException
      self.message = NullMessage
    end
  end
end
