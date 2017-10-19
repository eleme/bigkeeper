#!/usr/bin/env ruby

require './big_keeper/version'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/command/start_new_feature'
require './big_keeper/util/cache_operator'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/command/start_home_release'
require './big_keeper/command/start_module_release'

require 'gli'

include GLI::App

module BigKeeper

  # Your code goes here...
  program_desc 'Efficiency improvement for iOS modular development, iOSer using this tool can make modular development easier.'

  flag %i[p path], default_value: './'
  flag %i[u user], default_value: ''
  flag %i[v version], default_value: ''

  path, user, version = ''

  pre do |global_options, _command, options, args|
    path = global_options[:path]
    user = global_options[:user]
    version = global_options[:version]
  end

  desc 'Feature operations'
  command :feature do |c|
    c.desc 'Start a new feature with name for given modules and main project'
    c.command :start do |start|
      start.action do |global_options, options, args|
        help_now!('feature name and modules is required') if args.length != 2
        name = args[0]
        modules = args[1].split(",")
        start_new_feature(path, user, name, modules)
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
          # path(optional): path of the Bigkeeper file in project
          # version(optional): if null, will read verson in Bigkeeper file
          # e.g: ruby big_keeper.rb -p /Users/SFM/Downloads/BigKeeperMain-master
          # /Bigkeeper  -v 3.0.0 release home start
          start_home_release(path, version)
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
