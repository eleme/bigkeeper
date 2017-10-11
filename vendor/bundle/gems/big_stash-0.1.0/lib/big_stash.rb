#!/usr/bin/env ruby

require 'big_stash/version'
require 'big_stash/stash_operator'

require 'gli'

include GLI::App

module BigStash
  # Your code goes here...
  program_desc 'Enhancement for git stash'

  flag [:p,:path], :default_value => './'

  path = ''

  pre do |global_options,command,options,args|
    path = global_options[:path]
  end

  desc 'Add a stash with name'
  command :add do |c|
    c.action do |global_options, options, args|
      help_now!('stash name is required') if args.empty?
      BigStash::StashOperator.new(path).stash(args.first)
    end
  end

  desc 'Apply a stash with name'
  command :apply do |c|
    c.action do |global_options, options, args|
      help_now!('stash name is required') if args.empty?
      BigStash::StashOperator.new(path).apply_stash(args.first)
    end
  end

  desc 'List all the stashes'
  command :list do |c|
    c.action do
      p BigStash::StashOperator.new(path).stashes
    end
  end

  exit run(ARGV)
end
