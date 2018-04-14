class EventsPipeline
  class << self
    def process(event)
      event_handlers = EventHandlerProvider.get_all
      event_handlers.each do |event_handler|
        event_handler.handle(event)
      end
    end
  end
end
