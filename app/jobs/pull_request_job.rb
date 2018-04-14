class PullRequestJob < WebhooksJob
  def perform(payload)
    return unless payload[:action].in?(config.allowed_actions)

    repository_name = payload[:repository][:full_name]
    pull_request_number = payload[:number]

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
    match_result = branch_name.scan(config.jira_code_regex).first
    return nil if match_result.nil?
    match_result.first(2).map(&:upcase).join('-')
  end
end
