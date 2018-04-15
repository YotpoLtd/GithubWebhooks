class EventHandlerProvider
  @@registry = {}

  def self.get(job_class)
    registry_key = job_class.name.underscore

    handler = @@registry.fetch(registry_key, nil)
    return handler unless handler.nil?

    handler = EventHandler.new(job_class)
    @@registry[registry_key] = handler
    handler
  end

  def self.get_all
    @@registry.values
  end
end
