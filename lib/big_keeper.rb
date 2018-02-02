#!/usr/bin/env ruby

require 'big_keeper/version'

require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/git_operator'

require 'big_keeper/model/gitflow_type'

require 'big_keeper/command/feature&hotfix'
require 'big_keeper/command/release'
require 'big_keeper/command/pod'

require 'big_keeper/service/git_service'

require 'gli'

include GLI::App

module BigKeeper
  # Your code goes here...
  program_desc 'Efficiency improvement for iOS&Android module development, iOSer&Android using this tool can make module development easier.'

  flag %i[p path], default_value: './'
  flag %i[v ver], default_value: 'Version in Bigkeeper file'
  flag %i[u user], default_value: GitOperator.new.user.gsub(/[^0-9A-Za-z]/, '').downcase

  path = ''
  version = ''
  user = GitOperator.new.user

  pre do |global_options, _command, options, args|
    path = File.expand_path(global_options[:path])
    version = global_options[:ver]
    user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
  end

  if !GitflowOperator.new.verify_git_flow_command
    p %Q('git-flow' not found, use 'brew install git-flow' to install it)
    exit
  end

  feature_and_hotfix_command(:feature)

  feature_and_hotfix_command(:hotfix)

  release_command

  pod_command

  desc 'Show version of bigkeeper'
  command :version do |version|
    version.action do |global_options, options, args|
      p "bigkeeper (#{VERSION})"
    end
  end

  exit run(ARGV)
end
