class JobsDispatcher
  class << self
    def dispatch(event_name, payload)
      jobs_classes = MatchedJobsProvider.get_matched(event_name, payload)
      raise Exceptions::UnsupportedWebhookEventError.new(event_name) if jobs_classes.empty?

      jobs_classes.each { |job_class| job_class.perform_later(payload) }
    end
  end
end
