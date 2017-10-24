#!/usr/bin/env ruby

require './big_keeper/version'
require './big_keeper/util/bigkeeper_parser'
# require './big_keeper/command/feature_finish'
require './big_keeper/util/cache_operator'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/util/git_operator'
require './big_keeper/command/feature_start'
<<<<<<< HEAD
require './big_keeper/command/release_home'
require './big_keeper/command/release_module'
=======
require './big_keeper/command/start_home_release'
require './big_keeper/command/start_module_release'
>>>>>>> develop

require 'gli'

include GLI::App

module BigKeeper

  # Your code goes here...
  program_desc 'Efficiency improvement for iOS modular development, iOSer using this tool can make modular development easier.'

  flag %i[p path], default_value: './'
  flag %i[v version], default_value: 'Version in Bigkeeper file'
  path, version = ''
  pre do |global_options, _command, options, args|
<<<<<<< HEAD
    path = global_options[:path]
=======
    path = File.expand_path(global_options[:path])
>>>>>>> develop
    version = global_options[:version]
  end

  desc 'Feature operations'
  command :feature do |c|

    c.flag %i[u user], default_value: GitOperator.new.user
    user = GitOperator.new.user
    c.pre do |global_options, _command, options, args|
      user = global_options[:user]
    end

    c.desc 'Start a new feature with name for given modules and main project'
    c.command :start do |start|
      start.action do |global_options, options, args|
        help_now!('feature name is required') if args.length < 1
        name = args[0]
        modules = args[(1...args.length)] if args.length > 1
<<<<<<< HEAD
        start_new_feature(path, user, name, modules)
=======
        feature_start(path, user, name, modules)
>>>>>>> develop
      end
    end

    c.desc 'Switch to the feature with name'
    c.command :switch do |switch|
      switch.action do |global_options, options, args|
      end
    end

    c.desc 'Finish the feature with name'
    c.command :finish do |finish|
      finish.action do |global_options, options, args|
      end
    end

    c.desc 'List all the features'
    c.command :list do |list|
      list.action do
        BigkeeperParser.parse(File.expand_path(path))
        p CacheOperator.new.features_for_home(BigkeeperParser.home_name)
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
          # path(optional): project path
          # version(optional): if null, will read verson in Bigkeeper file
          # # e.g: ruby big_keeper.rb -p /Users/SFM/workspace/LPDTeamiOS -v 2.8.5 release home start
          # e.g: ruby big_keeper.rb -p /Users/SFM/workspace/BigKeeperMain -v 3.0.0 release home start
          release_home_start(path, version)
          start.command :release do |release|
              release.action do |global_options, options, args|
                release_home_finish(path, version)
              end
          end
        end
      end

      home.desc 'Finish release home project'
      home.command :finish do |finish|
        finish.action do |global_options, options, args|
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

  exit run(ARGV)
end
