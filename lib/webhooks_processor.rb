module WebhooksProcessor
  extend ActiveSupport::Concern
  include GithubWebhook::Processor

  included do
    ALLOWED_EVENTS.each do |allowed_event|
      define_method(:"github_#{allowed_event}") do |payload|
        EventRouter.perform(allowed_event, payload)
        render status: 200, json: '{}'
      end
    end
  end

  private

  def webhook_secret(_payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end
