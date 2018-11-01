
def getPuppetMasters
  m_file = ENV['REAKTOR_PUPPET_MASTERS_FILE']
  mastersFile = open(m_file)
  mastersFile.readlines
end

role(:puppet_master) {getPuppetMasters}
desc "for specified branch in puppetfile repo, use r10k to deploy all modules for the specified environment."

lock_file = "/var/tmp/r10k.lock"
date = `date`.chomp
if File.exists?(lock_file)
  puts "Aborting, r10k deploy already in progress"
  exit 1
end

puts "Creating lock file to avoid duplicate runs"
File.open(lock_file, 'w') { |file| file.write("#{date} - r10k locked for branch deploy") }

task "update_environment", :roles => :puppet_master do
  if exists?(:branchname)
    #run "r10k -v debug deploy environment #{branchname} -p"
    run "r10k deploy environment #{branchname} -p"
  else
    puts "Please provide a valid git branch name as an argument"
  end
end

desc "Deploy specified module in all environments using r10k"
task "deploy_module", :roles => :puppet_master do
  if exists?(:module_name)
    #run "r10k -v debug deploy module #{module_name}"
    run "r10k deploy module #{module_name}"
  else
    puts "Please provide a module name to deploy"
  end
end

puts "Cleaning up lockfile"
File.delete(lock_file) if File.exists?(lock_file)
