class WebhooksController < ApplicationController
  include GithubWebhook::Processor

  def create
    EventRouter.perform(event_method.to_s.sub!(/^github_/, ''), json_body)
    head(:ok)
  end

  private

  def webhook_secret(payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end
