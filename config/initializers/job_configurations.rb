jobs_conf_file = File.expand_path('../jobs/jobs.yml', __dir__)
jobs_config_options = YAML::load(ERB.new(IO.read(jobs_conf_file)).result)

jobs_config_options.each do |job_config|
  next if job_config.fetch('inactive', false)

  job_configuration = JobConfiguration.new(job_config)
  MatchedJobsProvider.register_job_configuration(job_configuration)
end
