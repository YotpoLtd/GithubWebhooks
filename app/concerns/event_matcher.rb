class EventMatcher
  def initialize(config)
    @event_name = config['event']
    @repositories = config['repositories'] || []
  end

  def match?(event)
    return false if event_name != event.name

    unless repositories == :all
      repository = event.payload['repository']['full_name']
      return false unless repository.in?(repositories)
    end

    true
  end

  private

  attr_reader :event_name
  attr_reader :repositories
end
