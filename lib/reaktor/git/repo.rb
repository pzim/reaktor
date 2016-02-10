require 'reaktor/commandrunner'

# Define a base class for git repositories.
class Reaktor::Git::Repo
  include Reaktor::CommandRunner

  # @!attribute [r] git_dir
  #   @return [String] The path to the git directory (checkoutdir/.git)
  attr_reader :git_dir

  private

  # Fetch from the given git remote
  #
  # @param remote [#to_s] The remote name to fetch from (default is origin)
  def fetch(remote = 'origin')
    git ['fetch', '--prune', remote], git_dir: @git_dir
  end

  # @param cmd [Array<String>] cmd The arguments for the git prompt
  # @param opts [Hash] opts
  #
  # @option opts [String] :path
  # @option opts [String] :git_dir
  # @option opts [String] :work_tree
  # @option opts [String] :raise_on_fail
  #
  # @raise [GitFailure] If the executed command exited with a
  #   nonzero exit code.
  #
  # @return [String] The git command output
  def git(cmd, opts = {})
    # raise_on_fail = opts.fetch(:raise_on_fail, true)

    argv = %w(git)

    if opts[:path]
      argv << '--git-dir'   << File.join(opts[:path], '.git')
      argv << '--work-tree' << opts[:path]
    else
      argv << '--git-dir' << opts[:git_dir] if opts[:git_dir]
      argv << '--work-tree' << opts[:work_tree] if opts[:work_tree]
    end

    argv.concat(cmd)
    # logger.info("#{self}: git command = #{argv}")

    # result = execute(argv)
    execute(argv)
  end
end
