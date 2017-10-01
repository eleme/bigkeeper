#!/usr/bin/env ruby

require 'big_keeper/version'
require 'big_keeper/util/bigkeeper_parser'

require 'gli'

include GLI::App

module BigKeeper
  # Your code goes here...
  program_desc 'Efficiency improvement for iOS modular development, iOSer using this tool can make modular development easier.'

  flag [:p,:path], :default_value => './'
  flag [:u,:user], :default_value => ''

  path, user = ''

  pre do |global_options,command,options,args|
    path = global_options[:path]
    user = global_options[:user]
  end

  BigkeeperParser.parse(path)

  command :feature do |c|
    desc 'Add a stash with name'
    command :apply do |c|
      c.action do |global_options, options, args|
        help_now!('stash name is required') if args.empty?
      end
    end
  end

  exit run(ARGV)
end
