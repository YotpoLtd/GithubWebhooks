class PullRequestJob < ApplicationJob
  queue_as :default

  def perform(payload)
    logger.debug(payload)
  end
end
