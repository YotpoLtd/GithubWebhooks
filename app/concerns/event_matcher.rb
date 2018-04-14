class EventMatcher
  def initialize(config)
    @event_name = config['event']

    unless config.key?('repositories')
      raise Exceptions::BadEventsConfigFileError.new("Missing repositories value on event config #{config['name']}")
    end
    @repositories = parse_repositories_patterns(config['repositories'])
  end

  def match?(event)
    return false if event_name != event.name

    repository_name = event.payload['repository']['full_name']
    return false if repositories.none? { |r| repository_name.match?(r) }

    true
  end

  private

  def parse_repositories_patterns(patterns)
    patterns = [patterns] unless patterns.is_a?(Array)
    patterns.map { |pattern| Common::StringUtils.parse_wildcards(pattern) }
  end

  attr_reader :event_name
  attr_reader :repositories
end
