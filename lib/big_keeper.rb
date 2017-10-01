#!/usr/bin/env ruby

require './big_keeper/version'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/command/start_new_feature'
require './big_keeper/util/cache_operator'
require './big_keeper/util/bigkeeper_parser'

require 'gli'

include GLI::App

module BigKeeper
  # Your code goes here...
  program_desc 'Efficiency improvement for iOS modular development, iOSer using this tool can make modular development easier.'

  flag %i[p path], default_value: './'
  flag %i[u user], default_value: ''

  path, user = ''

  pre do |global_options, _command, _options, _args|
    path = global_options[:path]
    user = global_options[:user]
  end

  desc 'Feature operations'
  command :feature do |c|
    c.desc 'Start a new feature with name for given modules and main project'
    c.command :start do |start|
      start.action do |_global_options, _options, _args|
        # start_new_feature(path, [])
      end
    end

    c.desc 'Switch to the feature with name'
    c.command :switch do |switch|
      switch.action do |_global_options, _options, _args|
      end
    end

    c.desc 'Finish the feature with name'
    c.command :finish do |finish|
      finish.action do |_global_options, _options, _args|
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
        start.action do |_global_options, _options, _args|
        end
      end
      home.desc 'Finish release home project'
      home.command :finish do |finish|
        finish.action do |_global_options, _options, _args|
        end
      end
    end

    c.desc 'Release a modular with name'
    c.command :modular do |modular|
      modular.action do |_global_options, _options, _args|
      end
    end
  end

  exit run(ARGV)
end
