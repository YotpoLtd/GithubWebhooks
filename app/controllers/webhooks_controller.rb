class WebhooksController < ApplicationController
  include GithubWebhook::Processor

  def create
    event = Event.new(event_name, json_body)
    EventsPipeline.process(event)
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
