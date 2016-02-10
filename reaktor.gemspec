# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reaktor/version'

Gem::Specification.new do |spec|
  spec.name          = "reaktor"
  spec.version       = Reaktor::VERSION
  spec.authors       = ["Phil Zimmerman"]
  spec.email         = ["pzimmerman.home@gmail.com"]

  spec.summary       = %q{Reaktor is a modular post-receive hook designed to work with r10k.}
  spec.description   = %q{Reaktor is a modular post-receive hook designed to
    work with r10k. It provides the energy to power the 10,000 killer robots in
    your Puppet infrastructure. The goal of reaktor is to automate as much as
    possible from the time puppet code is pushed through the point at which that
    code is deployed to your puppet masters and you've been notified accordingly.
    In most circumstances, there is no longer a need to manually edit the
    Puppetfile and ssh into the puppet masters to run r10k.}
  spec.homepage      = "https://github.com/pzim/reaktor"
  spec.license       = "Apache-2.0"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if RUBY_VERSION.to_f >= 2.0
    if spec.respond_to?(:metadata)
      spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
    else
      raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
    end
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "foreman"
  spec.add_dependency "god", "0.13.4"
  spec.add_dependency "json", "~> 1.8"
  spec.add_dependency "rdiscount"
  spec.add_dependency "redis", "3.0.7"
  spec.add_dependency "redis-objects", "0.9.1"
  spec.add_dependency "resque", "1.25.2"
  spec.add_dependency "resque-retry", "1.1.4"
  spec.add_dependency "sinatra", "1.4.5"
  spec.add_dependency "sinatra-contrib", "1.4.2"
  spec.add_dependency "thin", "1.6.2"
  if RUBY_VERSION.to_f < 2.0
    spec.add_dependency "net-ssh", "2.9.1"
  end

  ## gems for hipchat-api
  spec.add_dependency "capistrano", "2.15.5"
  spec.add_dependency "hipchat-api", "1.0.6"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "guard-rake"
  spec.add_development_dependency "jsonlint"
  spec.add_development_dependency "rack-test", "0.6.2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "3.0.0"
  spec.add_development_dependency "rubocop"
end

