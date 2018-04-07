class PullRequestJob < ApplicationJob
  queue_as :default

  ALLOWED_ACTIONS = %w(opened reopened)
  JIRA_CODE_PLACEHOLDER = '{{JIRA_CODE}}'
  JIRA_PROJECTS = %w(PUF)
  GITHUB_ORGANIZATION_NAME = 'YotpoLtd'
  ALLOWED_REPOSITORIES = %w(yotpo-email-templates)

  def perform(payload)
    return unless payload[:action].in?(ALLOWED_ACTIONS)

    repository_name = payload[:repository][:full_name]
    pull_request_number = payload[:number]

    return unless repository_name.match?(repository_name_regex)

    pull_request_data = Octokit.pull_request(repository_name, pull_request_number)

    return if pull_request_data[:state] != 'open'
    return if pull_request_data[:merged]

    pull_request_body = pull_request_data[:body]
    return if pull_request_body.index(JIRA_CODE_PLACEHOLDER).nil?

    head_branch_name = pull_request_data[:head][:ref]
    jira_code = extract_jira_code(head_branch_name)
    return if jira_code.nil?

    update_options = {
      body: pull_request_body.gsub(JIRA_CODE_PLACEHOLDER, jira_code)
    }
    Octokit.update_pull_request(repository_name, pull_request_number, update_options)
  end

  private

  def extract_jira_code(branch_name)
    match_result = branch_name.scan(jira_code_regex).first
    return nil if match_result.nil?
    match_result.first(2).map(&:upcase).join('-')
  end

  def jira_code_regex
    return @jira_code_regex unless @jira_code_regex.nil?
    jira_projects = JIRA_PROJECTS.map(&:downcase).map(&:strip).uniq
    pattern = "(^#{jira_projects.join('|')})-([0-9]+)(-|)"
    @jira_code_regex = Regexp.new(pattern, Regexp::IGNORECASE)
    @jira_code_regex
  end

  def repository_name_regex
    return @repository_name_regex unless @repository_name_regex.nil?
    repository_names = ALLOWED_REPOSITORIES.map(&:strip).uniq
    pattern = "(^#{GITHUB_ORGANIZATION_NAME})/(#{repository_names.join('|')})"
    @repository_name_regex = Regexp.new(pattern)
    @repository_name_regex
  end
end
