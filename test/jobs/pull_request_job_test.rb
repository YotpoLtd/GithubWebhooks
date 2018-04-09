require 'test_helper'

class PullRequestJobTest < ActiveJob::TestCase
  def setup
    @pull_request_response = {
      state: 'open',
      merged: false,
      body: '{{JIRA_CODE}}',
      head: {
        ref: 'puf-1989-adding-support-for-cool-stuff'
      }
    }
    Octokit.stubs(:pull_request).returns(@pull_request_response)
    Octokit.stubs(:update_pull_request)

    @job_payload = {
      action: 'opened',
      number: 13,
      repository: {
        full_name: 'YotpoLtd/GithubWebhooks'
      }
    }
  end

  test 'it should not update the PR if the repository is not one of the allowed' do
    Octokit.expects(:update_pull_request).never

    @job_payload[:repository][:full_name] = 'YotpoLtd/PrefixGithubWebhooks'
    PullRequestJob.perform_now(@job_payload)

    @job_payload[:repository][:full_name] = 'YotpoLtd/GithubWebhooksWithSuffix'
    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should not update the PR for other github organization' do
    Octokit.expects(:update_pull_request).never

    @job_payload[:repository][:full_name] = 'PrefixYotpoLtd/GithubWebhooks'
    PullRequestJob.perform_now(@job_payload)

    @job_payload[:repository][:full_name] = 'YotpoLtdSuffix/GithubWebhooks'
    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should invoke Octokit.pull_request with the repo name and PR number from the payload' do
    Octokit.unstub(:pull_request)

    Octokit.expects(:pull_request).with do |repository_name, pull_request_number|
      assert_equal(@job_payload[:repository][:full_name], repository_name)
      assert_equal(@job_payload[:number], pull_request_number)
      true
    end.returns(@pull_request_response)

    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should not update the PR if its status is not opened' do
    Octokit.unstub(:pull_request)
    @pull_request_response[:state] = 'closed'
    Octokit.stubs(:pull_request).returns(@pull_request_response)

    Octokit.expects(:update_pull_request).never

    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should not update the PR if its already merged' do
    Octokit.unstub(:pull_request)
    @pull_request_response[:merged] = true
    Octokit.stubs(:pull_request).returns(@pull_request_response)

    Octokit.expects(:update_pull_request).never

    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should not update the PR if the PR body does not contain variables' do
    Octokit.unstub(:pull_request)
    @pull_request_response[:body] = 'The body of the PR'
    Octokit.stubs(:pull_request).returns(@pull_request_response)

    Octokit.expects(:update_pull_request).never

    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should not update the PR if the head branch does not follow the format' do
    Octokit.unstub(:pull_request)
    @pull_request_response[:head][:ref] = 'puf1989-adding-support-for-cool-stuff'
    Octokit.stubs(:pull_request).returns(@pull_request_response)

    Octokit.expects(:update_pull_request).never

    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should update the correct PR' do
    Octokit.expects(:update_pull_request).with do |repository_name, pull_request_number, _update_options|
      assert_equal(@job_payload[:repository][:full_name], repository_name)
      assert_equal(@job_payload[:number], pull_request_number)
      true
    end

    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should update the PR body after injecting to the jira_code placeholder' do
    body = 'insert {{JIRA_CODE}} here'
    jira_code = 'PUF-420'
    expected_body = body.gsub('{{JIRA_CODE}}', jira_code)

    Octokit.expects(:update_pull_request).with do |_repository_name, _pull_request_number, update_options|
      assert_equal(expected_body, update_options[:body])
      true
    end

    @pull_request_response[:body] = body
    @pull_request_response[:head][:ref] = "#{jira_code}-doing-the-good-stuff"
    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should support multiple jira_code placeholders' do
    body = '| {{JIRA_CODE}} | {{JIRA_CODE}} |'
    jira_code = 'PUF-420'
    expected_body = body.gsub('{{JIRA_CODE}}', jira_code)

    Octokit.expects(:update_pull_request).with do |_repository_name, _pull_request_number, update_options|
      assert_equal(expected_body, update_options[:body])
      true
    end

    @pull_request_response[:body] = body
    @pull_request_response[:head][:ref] = "#{jira_code}-doing-the-good-stuff"
    PullRequestJob.perform_now(@job_payload)
  end

  test 'it should support branch name with mixed cased jira code format' do
    body = 'body of PR with head branch with mixed cased jira code format | inject please {{JIRA_CODE}}'
    jira_code = 'PUF-420'
    expected_body = body.gsub('{{JIRA_CODE}}', jira_code)

    Octokit.expects(:update_pull_request).with do |_repository_name, _pull_request_number, update_options|
      assert_equal(expected_body, update_options[:body])
      true
    end

    @pull_request_response[:body] = body
    mixed_cased_jira_code = 'pUf-420'
    @pull_request_response[:head][:ref] = "#{mixed_cased_jira_code}-doing-the-good-stuff"
    PullRequestJob.perform_now(@job_payload)
  end
end
