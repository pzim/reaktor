module Reaktor
  module GitAction
    require 'gitaction/action'
    require 'gitaction/create_action'
    require 'gitaction/delete_action'
    require 'gitaction/modify_action'
    require 'gitaction/action_controller'
    require 'utils/github_payload'
    require 'utils/gitlab_payload'
  end
end
