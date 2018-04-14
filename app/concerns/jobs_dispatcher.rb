class JobsDispatcher
  class << self
    def dispatch(event_method, payload)
      jobs_classes = MatchedJobsProvider.get_matched(event_method, payload)
      raise Exceptions::UnsupportedWebhookEventError.new(event_method) if jobs_classes.empty?

      jobs_classes.each { |job_class| job_class.perform_later(payload) }
    end
  end
end
