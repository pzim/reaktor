require 'slack-notifier'

notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
notifier.ping "Testing"
