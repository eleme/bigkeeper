require 'big_stash/stash_operator'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/util/git_operator'

module BigKeeper
  # Operator for got
  class StashService
    def stash(path, new_branch_name, user, modules)
      # Stash modules
      modules.each do |module_name|
        module_path = BigkeeperParser.module_full_path(path, user, module_name)
        branch_name = GitOperator.new.current_branch(module_path)

        if branch_name != new_branch_name
          p %Q(Current branch of '#{module_name}' is '#{branch_name}', start to stash...)
          BigStash::StashOperator.new(module_path).stash(branch_name)
        else
          p %Q(Current branch name of '#{module_name}' is the same with new branch, continue...)
        end
      end

      # Stash home
      branch_name = GitOperator.new.current_branch(path)
      if branch_name != new_branch_name
        p %Q(Current branch of home is '#{branch_name}', start to stash...)
        BigStash::StashOperator.new(path).stash(branch_name)
      else
        p "Current branch name of home is the same with new branch, continue..."
      end
    end

    def apply_stash(path, user, branch_name)
      home = BigkeeperParser.home_name
      modules = CacheOperator.new.modules_for_branch(home, name)

      # Stash modules
      modules.each do |item|
        module_path = BigkeeperParser.module_path(user, item)

        Dir.chdir(module_path) do
          BigStash::StashOperator.new(module_path).apply_stash(branch_name)
        end
      end

      # Stash home
      BigStash::StashOperator.new(path).apply_stash(branch_name)
    end
  end
end
