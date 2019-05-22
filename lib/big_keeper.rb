#!/usr/bin/env ruby

require 'big_keeper/version'

require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/git_operator'
require 'big_keeper/util/verify_operator'

require 'big_keeper/model/gitflow_type'

require 'big_keeper/command/feature&hotfix'
require 'big_keeper/command/release'
require 'big_keeper/command/pod'
require 'big_keeper/command/spec'
require 'big_keeper/command/image'
require 'big_keeper/command/init'
require 'big_keeper/service/git_service'
require 'big_keeper/util/leancloud_logger'

require 'gli'

include GLI::App

module BigKeeper
  # Your code goes here...
  program_desc 'Efficiency improvement for iOS&Android module development, iOSer&Android using this tool can make module development easier.'

  flag %i[p path], default_value: './'
  flag %i[v ver], default_value: 'Version in Bigkeeper file'
  flag %i[u user], default_value: GitOperator.new.user.gsub(/[^0-9A-Za-z]/, '').downcase
  flag %i[l log], default_value: true

  if VerifyOperator.already_in_process?
    p %Q(There is another 'big' command in process, please wait)
    exit
  end

  if !GitflowOperator.new.verify_git_flow_command
    p %Q('git-flow' not found, use 'brew install git-flow' to install it)
    exit
  end

  pre do |global_options,command,options,args|
    LeanCloudLogger.instance.start_log(global_options, args)
  end

  post do |global_options,command,options,args|
    LeanCloudLogger.instance.end_log(true, global_options[:log] == "true")
  end

  feature_and_hotfix_command(GitflowType::FEATURE)

  feature_and_hotfix_command(GitflowType::HOTFIX)

  release_command

  pod_command

  spec_command

  image_command

  init_command

  desc 'Show version of bigkeeper'
  command :version do |version|
    version.action do |global_options, options, args|
      LeanCloudLogger.instance.set_command("version")
      p "bigkeeper (#{VERSION})"
    end
  end

  exit run(ARGV)
end
