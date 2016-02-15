require 'reaktor/git'

class Reaktor::Git::WorkDir < Reaktor::Git::Repo
  # include Reaktor::Logging

  # @param path       [String]
  # @param url        [String]
  def initialize(path, url)
    @path = path
    @url  = url
    @git_dir = File.join(@path, '.git')
    @logger ||= Logger.new(STDOUT, Logger::INFO)
  end

  # clone the repo represented by @url at @path
  def clone
    unless dir_exist?
      git ['clone', '--branch production', @url, @path]
      fetch
    end
  end

  # check out the given ref
  #
  # @param branchname - The git branch to check out
  def checkout(branchname)
    fetch
    if !branch_exist?(branchname)
      @logger.info("branch #{branchname} doesn't exist. Create it now...")
      git ['checkout', '-b', branchname], path: @path
    else
      @logger.info("branch #{branchname} exists. Check it out now...")
      git ['fetch', 'origin', branchname], path: @path
      git ['checkout', '--force', branchname], path: @path
      # TODO: http://shorts.jeffkreeftmeijer.com/2014/compare-version-numbers-with-pessimistic-constraints/
      # --no-edit doesnt work in git 1.7.1 (RHEL)
      git ['merge', 'origin/production', '-X ours', '--no-edit'], path: @path
    end
  end

  # delete the given branch
  #
  # @param branchname - The git branch to delete
  def delete_branch(branchname)
    git ['push', 'origin', ":#{branchname}"], path: @path
  end

  # push changes in working dir to remote
  #
  # @param branchname - The git branch to push
  # @param commit_msg - The git commit message for this push
  def push(branchname, commit_msg)
    commit commit_msg
    pushed = git ['push', 'origin', branchname], path: @path
    if pushed.exitstatus == 0
      true
    else
      false
    end
  end

  # commit the current changes for this working dir
  def commit(commit_msg)
    # result = git ["commit", "-a", "-m", "\"#{commit_msg}\""], :path => @path
    git ['commit', '-a', '-m', "\"#{commit_msg}\""], path: @path
  end

  # Does a branch exist on the remote?
  # @return [true, false]
  def branch_exist?(branchname)
    git_remote_branch_cmd = "git ls-remote --heads #{@url} | cut -d '/' -f3"
    result = `#{git_remote_branch_cmd}`
    @logger.info("git remote branch cmd result: #{result}")
    branches = result.split
    @logger.info("branches after split: #{branches}")
    if branches.include? branchname
      return true
    else
      return false
    end
  end

  def destroy_workdir
    destroy_out = `rm -rf #{@path}`
    @logger.info("cleaning up: #{destroy_out}")
  end

  # Does a directory exist where we expect a working dir to be?
  # @return [true, false]
  def dir_exist?
    File.directory? @path
  end
end
