class Event
  attr_reader :name
  attr_reader :payload

  def initialize(name, payload)
    @name = name
    @payload = payload
  end
end
