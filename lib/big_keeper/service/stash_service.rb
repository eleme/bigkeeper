require 'big_stash/stash_operator'
require './big_keeper/util/cache_operator'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/util/git_operator'

module BigKeeper
  # Operator for got
  class StashService
    def stash(path, user)
      branch_name = current_branch(path)

      p branch_name

      home = BigkeeperParser.home_name
      modules = CacheOperator.new.modules_for_branch(home, branch_name)

      # Stash modules
      modules.each do |item|
        module_path = BigkeeperParser.module_path(user, item)

        Dir.chdir(module_path) do
          BigStash::StashOperator.new(module_path).stash(branch_name)
        end
      end

      # Stash home
      BigStash::StashOperator.new(path).stash(branch_name)
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
