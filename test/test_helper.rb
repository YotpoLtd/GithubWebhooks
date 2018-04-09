ENV['RAILS_ENV'] ||= 'test'

ENV['ALLOWED_PULL_REQUEST_ACTIONS'] ||= 'opened'
ENV['ALLOWED_JIRA_PROJECTS'] ||= 'puf'
ENV['ALLOWED_REPOSITORIES'] ||= 'GithubWebhooks'
ENV['GITHUB_ORGANIZATION_NAME'] ||= 'YotpoLtd'

ENV['WEBHOOKS_ALLOWED_EVENTS'] ||= 'pull_request'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/minitest'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end
