require 'big_keeper/service/git_service'
require 'big_keeper/util/logger'

module BigKeeper
  # Operator for got
  class ModuleService
    def pull(path, user, module_name, branch_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      Logger.highlight("Pull branch '#{branch_name}' for module '#{module_name}'...")

      if !File.exist? module_full_path
        Logger.default("No local repository for module '#{module_name}', clone it...")
        module_git = BigkeeperParser.module_git(module_name)
        GitOperator.new.clone(File.expand_path("#{module_full_path}/../"), module_git)
        GitOperator.new.git_checkout(module_full_path, branch_name)
      else
        current_branch_name = GitOperator.new.current_branch(module_full_path)
        if current_branch_name != branch_name
          Logger.default("Current branch of '#{module_name}' is '#{current_branch_name}',\
            stash it and checkout '#{branch_name}'...")

          StashService.new.stash(module_full_path, current_branch_name, module_name)

          GitOperator.new.git_checkout(module_full_path, branch_name)
        end
        GitOperator.new.pull(module_full_path)
      end
    end

    def switch(path, user, module_name, branch_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      Logger.highlight("Switch to branch '#{branch_name}' for module '#{module_name}'...")

      if !File.exist? module_full_path
        Logger.default("No local repository for module '#{module_name}', clone it...")
        module_git = BigkeeperParser.module_git(module_name)
        GitOperator.new.clone(File.expand_path("#{module_full_path}/../"), module_git)
        GitOperator.new.git_checkout(module_full_path, branch_name)
      else
        GitOperator.new.git_checkout(module_full_path, branch_name)
        GitOperator.new.pull(module_full_path)
      end

      StashService.new.pop_stash(module_full_path, branch_name, module_name)
    end

    def finish(path, user, module_name, type)
      module_git = BigkeeperParser.module_git(module_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      branch_name = GitOperator.new.current_branch(module_full_path)

      Logger.highlight("Finish branch '#{branch_name}' for module '#{module_name}'...")

      PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                           module_name,
                                           ModuleType::GIT,
                                           GitInfo.new(module_git, GitType::BRANCH, branch_name))

      GitService.new.verify_rebase(module_full_path, GitflowType.base_branch(type), module_name)

      `open #{BigkeeperParser.module_pulls(module_name)}`
    end

    def add(path, user, module_name, name, type)
      branch_name = "#{GitflowType.name(type)}/#{name}"

      Logger.highlight("Add branch '#{branch_name}' for module '#{module_name}'...")

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      # clone module if not exist
      if !File.exist? module_full_path
        Logger.default("No local repository for module #{module_name}, clone it...")
        module_git = BigkeeperParser.module_git(module_name)
        GitOperator.new.clone(File.expand_path("#{module_full_path}/../"), module_git)
      end

      # stash current branch
      current_branch_name = GitOperator.new.current_branch(module_full_path)

      StashService.new.stash(module_full_path, current_branch_name, module_name)

      # start new feature/hotfix
      GitService.new.start(module_full_path, name, type)

      StashService.new.pop_stash(module_full_path, branch_name, module_name)

      module_path = BigkeeperParser.module_path(user, module_name)

      PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                           module_name,
                                           ModuleType::PATH,
                                           module_path)
    end

    def del(path, user, module_name, name, type)
      branch_name = "#{GitflowType.name(type)}/#{name}"

      Logger.highlight("Delete branch '#{branch_name}' for module '#{module_name}'...")

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      StashService.new.stash(module_full_path, branch_name, module_name)

      GitOperator.new.git_checkout(module_full_path, 'develop')
      GitOperator.new.del(module_full_path, branch_name)

      module_git = BigkeeperParser.module_git(module_name)

      PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                           module_name,
                                           ModuleType::GIT,
                                           GitInfo.new(module_git, GitType::BRANCH, 'develop'))
    end
  end
end
