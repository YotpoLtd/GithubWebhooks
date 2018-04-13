jobs_conf_file = File.expand_path('../jobs.yml', __FILE__)
WEBHOOK_JOBS = YAML::load(ERB.new(IO.read(jobs_conf_file)).result).freeze
