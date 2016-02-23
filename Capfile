
def getPuppetMasters
  m_file = ENV['REAKTOR_PUPPET_MASTERS_FILE']
  mastersFile = open(m_file)
  mastersFile.readlines
end

role(:puppet_master) { getPuppetMasters }
desc 'for specified branch in puppetfile repo, use r10k to deploy all modules for the specified environment.'
task 'update_environment', roles: :puppet_master do
  if exists?(:branchname)
    # run "r10k -v debug deploy environment #{branchname} -p"
    run "r10k deploy environment #{branchname} -p"
  else
    puts 'Please provide a valid git branch name as an argument'
  end
end

desc 'Deploy specified module in all environments using r10k'
task 'deploy_module', roles: :puppet_master do
  if exists?(:module_name)
    # run "r10k -v debug deploy module #{module_name}"
    run "r10k deploy module #{module_name}"
  else
    puts 'Please provide a module name to deploy'
  end
end
#  vim: set ft=ruby ts=4 sw=2 tw=80 et :
