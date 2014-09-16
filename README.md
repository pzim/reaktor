# Reaktor

## Description

Reaktor is a modular post-receive hook designed to work with [r10k](https://github.com/adrienthebo/r10k). It provides the energy to power the 10,000 killer robots in your [Puppet](http://puppetlabs.com/) infrastructure. The goal of reaktor is to automate as much as possible from the time puppet code is pushed through the point at which that code is deployed to your puppet masters and you've been notified accordingly. In most circumstances, there is no longer a need to manually edit the Puppetfile and ssh into the puppet masters to run r10k. 

## Deeper Dive

Reaktor uses r10k to deploy your changes to all of your puppet masters and notifies you when it's finished so you know when your environment is ready.

Reaktor not only supports [puppet dynamic environments (via r10k)](http://puppetlabs.com/blog/git-workflow-and-puppet-environments), but also allows for Puppetfile dynamic branch creation. It provides notifications to [hipchat](http://hipchat.com) by default, but notifications are pluggable to work with other chat providers/notification types, e.g., [campfire](https://campfirenow.com/) and [slack](https://slack.com/). The default configuration supports [git webhook](https://developer.github.com/webhooks/) payloads from GitHub and GitHub Enterprise. The framework can be extended to support other git payload sources, such as [Stash](https://www.atlassian.com/software/stash).

Reaktor utilizes [resque](https://github.com/resque/resque) to provide event processing necessary for efficient puppet development workflow. Resque provides its own sinatra app to help monitor the state of events in the system.

### Requirements

	- Ruby (tested and verified with 1.9.3)
	- Git
	
### Installation

git clone git://github.com/pzim/reaktor  
cd reaktor  
bundle install

### User Requirements

The user you install and run reaktor as needs to have ssh trusts set up to the puppet masters.  
  
That same user must also have git commit privileges to your Github or Github Enterprise puppet module and puppetfile repositories. 

### Starting the post-receive hook
cd reaktor  
rake start (starts the post-receive hook and the resque workers)  

```
[jenkins@puppet-ci-01 reaktor]$ rake start
Starting server on puppet-ci-01.lab.webapps.rr.com:4570 ...
*** DEPRECATION WARNING: Resque::Worker#verbose and #very_verbose are deprecated. Please set Resque.logger.level instead
Called from: /usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/resque-1.25.2/lib/resque/worker.rb:746:in `verbose='
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/resque-1.25.2/lib/resque/tasks.rb:16:in `block (2 levels) in <top (required)>'
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/rake-10.3.2/lib/rake/task.rb:240:in `call'
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/rake-10.3.2/lib/rake/task.rb:240:in `block in execute'
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/rake-10.3.2/lib/rake/task.rb:235:in `each'
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/rake-10.3.2/lib/rake/task.rb:235:in `execute'
*** DEPRECATION WARNING: Resque::Worker#verbose and #very_verbose are deprecated. Please set Resque.logger.level instead
Called from: /usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/resque-1.25.2/lib/resque/worker.rb:746:in `verbose='
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/resque-1.25.2/lib/resque/tasks.rb:16:in `block (2 levels) in <top (required)>'
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/rake-10.3.2/lib/rake/task.rb:240:in `call'
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/rake-10.3.2/lib/rake/task.rb:240:in `block in execute'
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/rake-10.3.2/lib/rake/task.rb:235:in `each'
	/usr/local/rvm/gems/ruby-1.9.3-p448@reaktor/gems/rake-10.3.2/lib/rake/task.rb:235:in `execute'
*** DEPRECATION WARNING: Resque::Worker#verbose and #very_verbose are deprecated. Please set Resque.logger.level instead
```

### Environment Variables

Reaktor makes use of the following environment variables for configuration:  

##### REAKTOR_PUPPET_MASTERS_FILE (required) 

export REAKTOR_PUPPET_MASTERS_FILE="/path/to/masters.txt"  

Location of file containing all puppet masters. Each entry on a single line:  

puppet-master-01  
puppet-master-02  
...  

##### REAKTOR_PUPPETFILE_GIT_URL (required)

export REAKTOR_PUPPETFILE_GIT_URL="git@github.com:_org_/puppetfile.git"

##### REAKTOR_HIPCHAT_TOKEN (required if using hipchat)

auth token to enable posting hipchat messages

##### REAKTOR_HIPCHAT_ROOM (required if using hipchat)

name of hipchat room to send reaktor/r10k output notifications

##### REAKTOR_HIPCHAT_FROM (required if using hipchat)

user to send hipchat notifications as  

## Host and Port Configuration
Host and Port configuration is handled in the [reaktor/reaktor-cfg.yml](https://github.com/pzim/reaktor/blob/master/reaktor-cfg.yml) file: 
 
- The 'address' key is where you configure the hostname  
- The 'port' key is where you configure what port to listen on

These are the most important bits to configure, as they help make up the url for the webhook setting in your git repo config. For example: 
 
- address: myserver-01.puppet.com
- port: 4500

The resultant url (assuming you are using GitHub or GitHub Enterprise):  

- http://myserver-01.puppet.com:4500/github_payload

This is the url you would configure in the GitHub ServiceHooks Webhook URL for each internal puppet module.  

The reaktor/reaktor-cfg.yml has additional items that you can configure, including pidfile and log. 


## Pluggable Notifications  
The default IM tool for receiving reaktor notifications is [hipchat](http://hipchat.com). By setting the appropriate HIPCHAT-related environment variables above, you will receive hipchat notifications automatically.  

If you use a different IM tool, such as campfire or slack, you will need to implement the notifier accordingly. This is fairly straightforward. There are 2 directories under reaktor/lib/reaktor/notification: 
 
- active_notifiers (holds currently active notifiers) 
- available_notifiers (holds potential notifiers, but these aren't live)  

In order to implement a custom notifier do the following:  

- create the .rb file for your notifier and place it under the active_notifiers dir
- use the hipchat.rb as a reference, replacing 'class Hipchat' with an appropriate name, such as 'class Slack' (there is a dummy slack.rb file in available_notifiers as well)
- the new .rb file must implement the **_update_** method (again, use hipchat.rb as a reference)
- remove hipchat.rb from the active_notifiers dir
- restart the post-receive hook (rake stop; rake start)  




