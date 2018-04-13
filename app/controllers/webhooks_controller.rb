class WebhooksController < ApplicationController
  include GithubWebhook::Processor

  def create
    JobsDispatcher.dispatch(event_method.to_s.sub!(/^github_/, ''), json_body)
    head(:ok)
  end

  private

  def webhook_secret(_payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end
