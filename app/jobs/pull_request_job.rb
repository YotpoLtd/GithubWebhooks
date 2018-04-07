class PullRequestJob < ApplicationJob
  queue_as :default

  def self.configure &block
    block.call(config)
  end

  def self.config
    @config ||= OpenStruct.new
  end

  def config
    self.class.config
  end

  def perform(payload)
    return unless payload[:action].in?(config.allowed_actions)

    repository_name = payload[:repository][:full_name]
    pull_request_number = payload[:number]

    return unless repository_name.match?(repository_name_regex)

    pull_request_data = Octokit.pull_request(repository_name, pull_request_number)

    return if pull_request_data[:state] != 'open'
    return if pull_request_data[:merged]

    pull_request_body = pull_request_data[:body]
    return if pull_request_body.index(config.jira_code_placeholder).nil?

    head_branch_name = pull_request_data[:head][:ref]
    jira_code = extract_jira_code(head_branch_name)
    return if jira_code.nil?

    update_options = {
      body: pull_request_body.gsub(config.jira_code_placeholder, jira_code)
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
    pattern = "(^#{config.allowed_jira_projects.join('|')})-([0-9]+)(-|)"
    @jira_code_regex = Regexp.new(pattern, Regexp::IGNORECASE)
    @jira_code_regex
  end

  def repository_name_regex
    return @repository_name_regex unless @repository_name_regex.nil?
    repository_names = config.allowed_repositories.map(&:strip).uniq
    pattern = "(^#{config.organization_name})/(#{repository_names.join('|')})"
    @repository_name_regex = Regexp.new(pattern)
    @repository_name_regex
  end
end
