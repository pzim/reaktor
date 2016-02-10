module Reaktor
  module EventJobs
    require 'reaktor/jobs/event'
    require 'reaktor/jobs/create_event'
    require 'reaktor/jobs/delete_event'
    require 'reaktor/jobs/modify_event'
    require 'reaktor/jobs/controller'
    require 'reaktor/jobs/github_controller'
    require 'reaktor/jobs/gitlab_controller'
    require 'reaktor/jobs/stash_controller'
  end
end
