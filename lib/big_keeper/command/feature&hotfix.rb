require 'big_keeper/command/feature&hotfix/start'
require 'big_keeper/command/feature&hotfix/finish'
require 'big_keeper/command/feature&hotfix/switch'
require 'big_keeper/command/feature&hotfix/update'
require 'big_keeper/command/feature&hotfix/pull'
require 'big_keeper/command/feature&hotfix/push'
require 'big_keeper/command/feature&hotfix/rebase'
require 'big_keeper/command/feature&hotfix/publish'
require 'big_keeper/command/feature&hotfix/delete'

module BigKeeper
  def self.feature_and_hotfix_command(type)
    desc 'Gitflow feature operations'
    command type do |c|

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

      c.desc "Rebase 'develop' to current feature"
      c.command :rebase do |rebase|
        rebase.action do |global_options, options, args|
          help_now!('user name is required') if user and user.empty?
          rebase(path, user, GitflowType::FEATURE)
        end
      end

      c.desc 'Finish current feature'
      c.command :finish do |finish|
        finish.action do |global_options, options, args|
          help_now!('user name is required') if user and user.empty?
          finish(path, user, GitflowType::FEATURE)
        end
      end

      c.desc 'Publish current feature'
      c.command :publish do |publish|
        publish.action do |global_options, options, args|
          help_now!('user name is required') if user and user.empty?
          publish(path, user, GitflowType::FEATURE)
        end
      end

      c.desc 'Delete feature with name'
      c.command :delete do |delete|
        delete.action do |global_options, options, args|
          help_now!('user name is required') if user and user.empty?
          help_now!('feature name is required') if args.length < 1
          name = args[0]
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
  end
end
