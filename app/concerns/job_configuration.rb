class JobConfiguration
  def initialize(config)
    @job_event_name = config['event']

    if config.key?('job_class')
      @job_class = config['job_class'].constantize
    else
      @job_class = [@job_event_name, 'job'].join('_').camelize.constantize
    end

    @job_repositories = config['repositories'] || []
  end

  def should_process?(event_name, payload)
    return false if job_event_name != event_name

    unless job_repositories == :all
      repository = payload['repository']['full_name']
      return false unless repository.in?(job_repositories)
    end

    true
  end

  attr_reader :job_class

  private

  attr_reader :job_event_name
  attr_reader :job_repositories
end
