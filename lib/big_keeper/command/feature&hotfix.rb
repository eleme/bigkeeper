require 'big_keeper/command/feature&hotfix/start'
require 'big_keeper/command/feature&hotfix/finish'
require 'big_keeper/command/feature&hotfix/switch'
require 'big_keeper/command/feature&hotfix/update'
require 'big_keeper/command/feature&hotfix/pull'
require 'big_keeper/command/feature&hotfix/push'
require 'big_keeper/command/feature&hotfix/rebase'
require 'big_keeper/command/feature&hotfix/publish'
require 'big_keeper/command/feature&hotfix/delete'
require 'big_keeper/command/feature&hotfix/list'

module BigKeeper
  def self.feature_and_hotfix_command(type)
    desc "Gitflow #{GitflowType.name(type)} operations"
    command GitflowType.command(type) do |c|
      c.desc "Start a new #{GitflowType.name(type)} with name for given modules and main project"
      c.command :start do |start|
        start.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          help_now!("#{GitflowType.name(type)} name is required") if args.length < 1
          name = args[0]
          modules = args[(1...args.length)] if args.length > 1
          start(path, version, user, name, modules, type)
        end
      end

      c.desc "Update modules for the #{GitflowType.name(type)} with name"
      c.command :update do |update|
        update.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          modules = args[(0...args.length)] if args.length > 0
          update(path, user, modules, type)
        end
      end

      c.desc "Switch to the #{GitflowType.name(type)} with name"
      c.command :switch do |switch|
        switch.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          help_now!("#{GitflowType.name(type)} name is required") if args.length < 1
          name = args[0]
          switch_to(path, version, user, name, type)
        end
      end

      c.desc "Pull remote changes for current #{GitflowType.name(type)}"
      c.command :pull do |pull|
        pull.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          pull(path, user, type)
        end
      end

      c.desc "Push local changes to remote for current #{GitflowType.name(type)}"
      c.command :push do |push|
        push.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          help_now!('comment message is required') if args.length < 1
          help_now!(%Q(comment message should be wrappered with '' or "")) if args.length > 1
          comment = args[0]
          push(path, user, comment, type)
        end
      end

      c.desc "Rebase '#{GitflowType.base_branch(type)}' to current #{GitflowType.name(type)}"
      c.command :rebase do |rebase|
        rebase.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          rebase(path, user, type)
        end
      end

      c.desc "Finish current #{GitflowType.name(type)}"
      c.command :finish do |finish|
        finish.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          finish(path, user, type)
        end
      end

      c.desc "Publish current #{GitflowType.name(type)}"
      c.command :publish do |publish|
        publish.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          publish(path, user, type)
        end
      end

      c.desc "Delete #{GitflowType.name(type)} with name"
      c.command :delete do |delete|
        delete.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          help_now!('user name is required') if user and user.empty?
          help_now!("#{GitflowType.name(type)} name is required") if args.length < 1
          name = args[0]
          delete(path, user, name, type)
        end
      end

      c.desc "List all the #{GitflowType.name(type)}s"
      c.command :list do |list|
        list.flag %i[v version] , default_value: 'all versions'
        list.desc "Print list of TREE format."
        list.command :tree do |tree|
          tree.action do |global_options, options, args|
            Logger.highlight("Generating feature tree of all version...") if args.length < 1
            path = File.expand_path(global_options[:path])
            user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
            list(path,user,type,options)
          end
        end

        list.desc "Print list of JSON format."
        list.command :json do |json|
          json.action do |global_options, options, args|
            options[:json] = true
            Logger.highlight("Generating feature json of all version...") if args.length < 1
            path = File.expand_path(global_options[:path])
            user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
            list(path,user,type,options)
          end
        end
      end
    end
  end
end
