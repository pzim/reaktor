# Reaktor

[![Build Status](https://travis-ci.org/timhughes/reaktor.svg?branch=master)](https://travis-ci.org/timhughes/reaktor)
[![Coverage Status](https://coveralls.io/repos/timhughes/reaktor/badge.svg?branch=master&service=github)](https://coveralls.io/github/timhughes/reaktor?branch=master)

[![Code Climate](https://codeclimate.com/github/timhughes/reaktor/badges/gpa.svg)](https://codeclimate.com/github/timhughes/reaktor)
[![Test Coverage](https://codeclimate.com/github/timhughes/reaktor/badges/coverage.svg)](https://codeclimate.com/github/timhughes/reaktor/coverage)
[![Issue Count](https://codeclimate.com/github/timhughes/reaktor/badges/issue_count.svg)](https://codeclimate.com/github/timhughes/reaktor)


## Description

Reaktor is a modular post-receive hook designed to work with [r10k](https://github.com/adrienthebo/r10k). It provides the energy to power the 10,000 killer robots in your [Puppet](http://puppetlabs.com/) infrastructure. The goal of reaktor is to automate as much as possible from the time puppet code is pushed through the point at which that code is deployed to your puppet masters and you've been notified accordingly. In most circumstances, there is no longer a need to manually edit the Puppetfile and ssh into the puppet masters to run r10k.

## Deeper Dive

Reaktor uses r10k to deploy your changes to all of your puppet masters and notifies you when it's finished so you know when your environment is ready.

Reaktor not only supports [puppet dynamic environments (via r10k)](http://puppetlabs.com/blog/git-workflow-and-puppet-environments), but also allows for Puppetfile dynamic branch creation. It provides notifications to [slack](http://slack.com) by default. The default configuration supports [git webhook](https://developer.github.com/webhooks/) payloads from GitHub and GitHub Enterprise. In addition, reaktor supports the following git sources:  
 	- [Stash](https://www.atlassian.com/software/stash)  
 	- [Gitlab](https://about.gitlab.com/)

Reaktor utilizes [resque](https://github.com/resque/resque) to provide event processing necessary for efficient puppet development workflow. Resque provides its own sinatra app to help monitor the state of events in the system.

### Requirements

    - Ruby (tested and verified with 1.9.3)
    - Git
    - Redis (needed for resque to work properly)

### Installation

git clone git://github.com/pzim/reaktor  
cd reaktor  
bundle install

### User Requirements

The user you install and run reaktor as needs to have ssh trusts set up to the puppet masters.

That same user must also have git commit privileges to your Github or Github Enterprise puppet module and puppetfile repositories.

### Starting the post-receive hook

**ensure redis is installed and running**  
cd reaktor  
rake start (starts the post-receive hook and the resque workers)  

```
[jenkins@test-box-01 reaktor]$ rake start
Starting server on test-box-01:4570 ...
```

### Environment Variables

Reaktor makes use of the following environment variables for configuration:

##### REAKTOR_PUPPET_MASTERS_FILE (required)

`export REAKTOR_PUPPET_MASTERS_FILE="/path/to/masters.txt"`

Location of file containing all puppet masters. Each entry on a single line:

```
puppet-master-01
puppet-master-02
...
```

##### PUPPETFILE_GIT_URL (required)

`export PUPPETFILE_GIT_URL="git@github.com:_org_/puppetfile.git"`

##### RESQUE_WORKER_USER (defaults to 'jenkins')

user used to start resque processes

##### RESQUE_WORKER_GROUP (defaults to 'jenkins')

group used to start resque processes

##### RACK_ROOT (defaults to '/data/apps/sinatra/reaktor')

set this to the fully qualified path where you installed reaktor (temporary until code is modified to auto-discover base dir)

## Host and Port Configuration (for thin server)

Host and Port configuration is handled in the [reaktor/reaktor-cfg.yml](https://github.com/pzim/reaktor/blob/master/reaktor-cfg.yml) file:

- The 'address' key is where you configure the hostname
- The 'port' key is where you configure what port to listen on

These are the most important bits to configure, as they help make up the url for the webhook setting in your git repo config. For example:

- address: myserver-01.puppet.com
- port: 4500

The resultant url (assuming you are using GitHub or GitHub Enterprise):

- http://myserver-01.puppet.com:4500/github_payload

If you are using Atlassian Stash:

- http://myserver-01.puppet.com:4500/stash_payload  

If you are using Gitlab:

- http://myserver-01.puppet.com:4500/gitlab_payload

This is the url you would configure in the GitHub ServiceHooks Webhook URL for each internal puppet module.

The reaktor/reaktor-cfg.yml has additional items that you can configure, including pidfile and log.


## Notifications
Reaktor now only supports notifications to slack via webhook.
More than one active room can be used by configuring the required slack channels in the config/notifiers.yml file and then referencing this channel key with the message call.  
