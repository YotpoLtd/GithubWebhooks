class WebhooksController < ApplicationController
  include GithubWebhook::Processor

  def create
    JobsDispatcher.dispatch(event_name, json_body)
    head(:ok)
  end

  private

  def event_name
    @event_name ||= request.headers['X-GitHub-Event']
  end

  def webhook_secret(_payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end
