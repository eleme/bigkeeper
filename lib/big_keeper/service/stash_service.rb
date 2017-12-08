require 'big_stash/stash_operator'
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/git_operator'
require 'big_keeper/util/logger'

module BigKeeper
  # Operator for got
  class StashService
    def pop_stash(path, branch_name, name)
      # pop stash
      if BigStash::StashOperator.new(path).stash_for_name(branch_name)
        Logger.highlight(%Q(Branch '#{branch_name}' of '#{name}' has stash , start to pop...))
        BigStash::StashOperator.new(path).pop_stash(branch_name)
      end
    end

    def stash(path, branch_name, name)
      # stash
      if GitOperator.new.has_changes(path)
        Logger.highlight(%Q(Branch '#{branch_name}' of '#{name}' needs stash , start to stash...))
        BigStash::StashOperator.new(path).stash(branch_name)
      end
    end

    def stash_all(path, new_branch_name, user, modules)
      # Stash modules
      Logger.highlight('Stash for current workspace...')

      modules.each do |module_name|
        module_path = BigkeeperParser.module_full_path(path, user, module_name)
        branch_name = GitOperator.new.current_branch(module_path)

        if branch_name != new_branch_name
          stash(module_path, branch_name, module_name)
        end
      end

      # Stash home
      branch_name = GitOperator.new.current_branch(path)
      if branch_name != new_branch_name
        stash(path, branch_name, 'Home')
      end
    end
  end
end
