class WebhooksJob < ApplicationJob
  queue_as :default

  def self.configure &block
    block.call(config)
  end

  def self.config
    @config ||= OpenStruct.new
  end

  def config
    self.class.config
  end
end
