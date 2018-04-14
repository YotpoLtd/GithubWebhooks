class EventHandler
  def initialize(job_class)
    @job_class = job_class
    @event_matchers = []
  end

  def register_matcher(event_matcher)
    event_matchers << event_matcher
  end

  def handle(event)
    return unless event_matchers.any? { |matcher| matcher.match?(event) }
    job_class.perform_later(event.payload)
  end

  private

  attr_reader :job_class
  attr_reader :event_matchers
end
