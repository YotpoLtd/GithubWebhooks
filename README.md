# README

This is a simple Github webhooks Rails server.

Make sure you have rvm set up according to the ```.ruby-*``` files.

```
gem install bundler
bundle install
```

Export some envs

```
export GITHUB_WEBHOOK_SECRET={{YOUR_SECRET_HERE}}
export OCTOKIT_ACCESS_TOKEN={{YOUR_TOKEN_HERE}}
export ALLOWED_REPOSITORIES=yotpo-email-templates
export GITHUB_ORGANIZATION_NAME=YotpoLtd
export ALLOWED_JIRA_PROJECTS=puf yo
export ALLOWED_PULL_REQUEST_ACTIONS=edited opened reopened
export WEBHOOKS_ALLOWED_EVENTS=pull_request
```

And fire it up with ```rails s```.