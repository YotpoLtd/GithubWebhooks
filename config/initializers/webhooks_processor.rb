module WebhooksProcessor
  # export WEBHOOKS_ALLOWED_EVENTS="pull_request release"
  allowed_events = (ENV['WEBHOOKS_ALLOWED_EVENTS'] || '').split
  raise StandardError, 'Mandatory env WEBHOOKS_ALLOWED_EVENTS is missing or empty' if allowed_events.empty?
  bad_events = allowed_events.reject { |event| event.in?(GithubWebhook::Processor::GITHUB_EVENTS_WHITELIST) }
  raise StandardError, "Events (#{bad_events.join(' ')}) are illegal" if bad_events.any?
  ALLOWED_EVENTS = allowed_events
end
