#!/usr/bin/env ruby

require 'big_keeper/version'

require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/git_operator'

require 'big_keeper/model/gitflow_type'

require 'big_keeper/command/feature&hotfix/start'
require 'big_keeper/command/feature&hotfix/finish'
require 'big_keeper/command/feature&hotfix/switch'
require 'big_keeper/command/feature&hotfix/update'
require 'big_keeper/command/feature&hotfix/pull'
require 'big_keeper/command/feature&hotfix/push'
require 'big_keeper/command/feature&hotfix/delete'
require 'big_keeper/command/release/home'
require 'big_keeper/command/release/module'
require 'big_keeper/command/pod/podfile_lock'

require 'big_keeper/service/git_service'

require 'gli'

include GLI::App

module BigKeeper
  # Your code goes here...
  program_desc 'Efficiency improvement for iOS&Android modular development, iOSer&Android using this tool can make modular development easier.'

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
        start(path, version, user, name, modules, GitflowType::FEATURE)
      end
    end

    c.desc 'Update modules for the feature with name'
    c.command :update do |update|
      update.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        modules = args[(0...args.length)] if args.length > 0
        update(path, user, modules, GitflowType::FEATURE)
      end
    end

    c.desc 'Switch to the feature with name'
    c.command :switch do |switch|
      switch.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('feature name is required') if args.length < 1
        name = args[0]
        switch_to(path, version, user, name, GitflowType::FEATURE)
      end
    end

    c.desc 'Pull remote changes for current feature'
    c.command :pull do |pull|
      pull.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        pull(path, user, GitflowType::FEATURE)
      end
    end

    c.desc 'Push local changes to remote for current feature'
    c.command :push do |push|
      push.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('comment message is required') if args.length < 1
        help_now!(%Q(comment message should be wrappered with '' or "")) if args.length > 1
        comment = args[0]
        push(path, user, comment, GitflowType::FEATURE)
      end
    end

    c.desc 'Finish current feature'
    c.command :finish do |finish|
      finish.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        finish(path, user, GitflowType::FEATURE)
      end
    end

    c.desc 'Delete feature with name'
    c.command :delete do |delete|
      finish.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('feature name is required') if args.length < 1
        delete(path, user, name, GitflowType::FEATURE)
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

  desc 'Hotfix operations'
  command :hotfix do |c|

    c.desc 'Start a new hotfix with name for given modules and main project'
    c.command :start do |start|
      start.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('hotfix name is required') if args.length < 1
        name = args[0]
        modules = args[(1...args.length)] if args.length > 1
        start(path, version, user, name, modules, GitflowType::HOTFIX)
      end
    end

    c.desc 'Update modules for the hotfix with name'
    c.command :update do |update|
      update.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        modules = args[(0...args.length)] if args.length > 0
        update(path, user, modules, GitflowType::HOTFIX)
      end
    end

    c.desc 'Switch to the hotfix with name'
    c.command :switch do |switch|
      switch.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('hotfix name is required') if args.length < 1
        name = args[0]
        switch_to(path, version, user, name, GitflowType::HOTFIX)
      end
    end

    c.desc 'Pull remote changes for current hotfix'
    c.command :pull do |pull|
      pull.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        pull(path, user, GitflowType::HOTFIX)
      end
    end

    c.desc 'Push local changes to remote for current hotfix'
    c.command :push do |push|
      push.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('comment message is required') if args.length < 1
        help_now!(%Q(comment message should be wrappered with '' or "")) if args.length > 1
        comment = args[0]
        push(path, user, comment, GitflowType::HOTFIX)
      end
    end

    c.desc 'Finish current hotfix'
    c.command :finish do |finish|
      finish.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        finish(path, user, GitflowType::HOTFIX)
      end
    end

    c.desc 'Delete hotfix with name'
    c.command :delete do |delete|
      finish.action do |global_options, options, args|
        help_now!('user name is required') if user and user.empty?
        help_now!('feature name is required') if args.length < 1
        delete(path, user, name, GitflowType::HOTFIX)
      end
    end

    c.desc 'List all the hotfixes'
    c.command :list do |list|
      list.action do
        branchs = GitService.new.branchs_with_type(File.expand_path(path), GitflowType::HOTFIX)
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
          help_now!('user name is required') if user and user.empty?
          raise Logger.error("release version is required") if version == nil
          release_home_start(path, version, user)
        end
      end

      home.desc 'Finish release home project'
      home.command :finish do |finish|
        finish.action do |global_options, options, args|
          raise Logger.error("release version is required") if version == nil
          release_home_finish(path, version)
        end
      end
    end

    c.desc 'release module'
    c.command :module do |m|
      m.desc 'Start release module project'
      m.command :start do |start|
        start.action do |global_options, options, args|
          help_now!('module name is required') if args.length != 1
          raise Logger.error("release version is required") if version == nil
          module_name = args[0]
          release_module_start(path, version, user, module_name)
        end
      end

      m.desc 'finish release module project'
      m.command :finish do |finish|
        finish.action do |global_options, options, args|
          help_now!('module name is required') if args.length != 1
          raise Logger.error("release version is required") if version == nil
          module_name = args[0]
          release_module_finish(path, version, user, module_name)
        end
      end
    end

  end

  desc 'Podfile operation'
  command :podfile do |podfile|
    podfile.flag %i[pod podfile]
    podfile.desc 'Podfile'
    path = ''

    podfile.desc 'Detect podname should be locked.'
    podfile.command :detect do |detect|
      detect.action do |global_options,options,args|
        podfile_detect(path)
      end
    end

    podfile.desc 'Lock podname should be locked.'
    podfile.command :lock do |lock|
      lock.action do |global_options, options, args|
        podfile_lock(path)
      end
    end
  end

  desc 'Version'
  command :version do |version|
    version.action do |global_options, options, args|
      p "big-keeper (#{VERSION})"
    end
end
  exit run(ARGV)
end
