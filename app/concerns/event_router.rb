class EventRouter
  def self.perform(event_method, payload)
    job_class = [event_method, 'job'].join('_').camelize.constantize
    job_class.perform_later(payload)
  end
end
