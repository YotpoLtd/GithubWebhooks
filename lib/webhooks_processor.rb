module WebhooksProcessor
  extend ActiveSupport::Concern
  include GithubWebhook::Processor

  included do
    ALLOWED_EVENTS.each do |allowed_event|
      define_method(:"github_#{allowed_event}") do |payload|
        job_class = [allowed_event, 'job'].join('_').camelize.constantize
        job_class.perform_later(payload)
        render status: 200, json: '{}'
      end
    end
  end

  private

  def webhook_secret(payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end