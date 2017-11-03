#!/usr/bin/env ruby

require 'big_keeper/version'

require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/git_operator'

require 'big_keeper/model/gitflow_type'

require 'big_keeper/command/feature_start'
require 'big_keeper/command/feature_finish'
require 'big_keeper/command/feature_switch'
require 'big_keeper/command/feature_update'
require 'big_keeper/command/feature_pull'
require 'big_keeper/command/feature_push'
require 'big_keeper/command/release_home'
require 'big_keeper/command/release_module'
require 'big_keeper/command/podfile_lock'

require 'big_keeper/service/git_service'

require 'gli'

include GLI::App

module BigKeeper
  # Your code goes here...
  program_desc 'Efficiency improvement for iOS modular development, iOSer using this tool can make modular development easier.'

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

  desc 'Feature operations'
  command :feature do |c|

    c.desc 'Start a new feature with name for given modules and main project'
    c.command :start do |start|
      start.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('feature name is required') if args.length < 1
        name = args[0]
        modules = args[(1...args.length)] if args.length > 1
        feature_start(path, version, user, name, modules)
      end
    end

    c.desc 'Update moduels for the feature with name'
    c.command :update do |update|
      update.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        modules = args[(0...args.length)] if args.length > 0
        feature_update(path, user, modules)
      end
    end

    c.desc 'Switch to the feature with name'
    c.command :switch do |switch|
      switch.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('feature name is required') if args.length < 1
        name = args[0]
        feature_switch(path, version, user, name)
      end
    end

    c.desc 'Pull remote changes for current feature'
    c.command :pull do |pull|
      pull.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        feature_pull(path, user)
      end
    end

    c.desc 'Push local changes to remote for current feature'
    c.command :push do |push|
      push.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('comment message is required') if args.length < 1
        comment = args[0]
        feature_push(path, user, comment)
      end
    end

    c.desc 'Finish current feature'
    c.command :finish do |finish|
      finish.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        feature_finish(path, user)
      end
    end

    c.desc 'List all the features'
    c.command :list do |list|
      list.action do
        branchs = GitService.new.branchs_with_type(File.expand_path(path), GitflowType::FEATURE)
        branchs.each do |branch|
          p branch
        end
      end
    end
  end

  desc 'Release operations'
  command :release do |c|

    c.desc 'Release home project operations'
    c.command :home do |home|
      home.desc 'Start release home project'
      home.command :start do |start|
        start.action do |global_options, options, args|
          # path(optional): path of the Bigkeeper file in project
          # version(optional): if null, will read verson in Bigkeeper file
          # e.g: ruby big_keeper.rb -p /Users/SFM/Downloads/BigKeeperMain-master
          # /Bigkeeper  -v 3.0.0 release home start
          help_now!('user name is required') if user and user.empty?
          release_home_start(path, version, user)
        end
      end

      home.desc 'Finish release home project'
      home.command :finish do |finish|
        finish.action do |global_options, options, args|
          release_home_finish(path, version)
        end
      end

      home.desc 'Start release module'
      home.command :module do |finish|
        finish.action do |global_options, options, args|
          help_now!('module name is required') if args.length != 1
          module_name = args[0]
          start_module_release(path, module_name)
        end
      end
    end
  end

  desc 'Lock Podfile operation'
  command :podfile do |podfile|
    podfile.flag %i[pod podfile]
    podfile.desc 'Podfile'
    path = ''
    podfile.pre do |global_options, _command, options, args|
      path = File.expand_path(global_options[:home])
    end

    podfile.command :detect do |detect|
      detect.desc 'Detect podname should be locked.'
      detect.action do |global_options,options,args|
        podfile_detect(path)
      end

      detect.command :lock do |lock|
        lock.action do |global_options, options, args|
          podfile_lock(path)
        end
      end
  end
end
  exit run(ARGV)
end
