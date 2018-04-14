events_conf_file = File.expand_path('../events/events.yml', __dir__)
event_configs = YAML::load(ERB.new(IO.read(events_conf_file)).result)

event_configs.each do |event_config|
  next if event_config.fetch('inactive', false)

  job_class_name = event_config.fetch('job_class') do |_key|
    [event_config['event'], 'job'].join('_').camelize
  end
  job_class = job_class_name.constantize

  event_handler = EventHandlerProvider.get(job_class)
  event_handler.register_matcher(EventMatcher.new(event_config))
end
