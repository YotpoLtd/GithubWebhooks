class MatchedJobsProvider
  class << self
    attr_accessor :job_configurations
  end
  @job_configurations = []

  def self.get_matched(event_method, payload)
    matched_job_configurations = job_configurations.select do |job_configuration|
      job_configuration.should_process?(event_method, payload)
    end

    matched_job_configurations.map(&:job_class).uniq
  end

  def self.register_job_configuration(job_configuration)
    job_configurations << job_configuration
  end
end
