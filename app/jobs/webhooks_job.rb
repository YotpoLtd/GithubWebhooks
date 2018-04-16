class WebhooksJob < ApplicationJob
  queue_as :default

  def self.config
    return @config unless @config.nil?

    yaml = Pathname.new(config_file)
    @config = YAML.load(ERB.new(yaml.read).result)['config']
    @config
  end

  def config
    self.class.config
  end

  def self.config_file
    filename = self.name.underscore
    File.expand_path("../../config/jobs/#{filename}.yml", __dir__)
  end

  private_class_method :config_file
end
