class JobsDispatcher
  class << self
    def dispatch(event_method, payload)
      job_to_perform = WEBHOOK_JOBS.find do |job|
        job['event_method'] == event_method
      end

      raise Exceptions::UnsupportedWebhookEventError.new(event_method) if job_to_perform.nil?

      job_class = [event_method, 'job'].join('_').camelize.constantize
      job_class.perform_later(payload)
    end
  end
end
