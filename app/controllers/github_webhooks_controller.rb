class GithubWebhooksController < ApplicationController
  include GithubWebhook::Processor

  def github_pull_request(payload)
    PullRequestJob.perform_later(payload)
    render status: 200, json: '{}'
  end

  private

  def webhook_secret(payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end