PullRequestJob.configure do |conf|
  allowed_actions = (ENV['ALLOWED_PULL_REQUEST_ACTIONS'] || 'opened reopened').split.map(&:downcase).map(&:strip).uniq
  conf.allowed_actions = allowed_actions

  # export ALLOWED_JIRA_PROJECTS="PUF YO"
  allowed_jira_projects = (ENV['ALLOWED_JIRA_PROJECTS'] || '').split.map(&:downcase).map(&:strip).uniq
  raise StandardError, 'Mandatory env ALLOWED_JIRA_PROJECTS is missing or empty' if allowed_jira_projects.empty?
  conf.allowed_jira_projects = allowed_jira_projects

  # export ALLOWED_REPOSITORIES="repo-name"
  allowed_repositories = (ENV['ALLOWED_REPOSITORIES'] || '').split.map(&:downcase).map(&:strip).uniq
  raise StandardError, 'Mandatory env ALLOWED_REPOSITORIES is missing or empty' if allowed_repositories.empty?
  conf.allowed_repositories = allowed_repositories

  conf.jira_code_placeholder = '{{JIRA_CODE}}'

  # export GITHUB_ORGANIZATION_NAME="YotpoLtd"
  organization_name = ENV['GITHUB_ORGANIZATION_NAME']
  raise StandardError, 'Mandatory env GITHUB_ORGANIZATION_NAME is missing or empty' if organization_name.blank?
  conf.organization_name = organization_name
end
