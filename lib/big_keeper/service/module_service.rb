require 'big_keeper/service/git_service'

require 'big_keeper/util/logger'
require 'big_keeper/util/cache_operator'

module BigKeeper
  # Operator for got
  class ModuleService

    def verify_module(path, user, module_name, home_branch_name, type)
      name = home_branch_name.gsub(/#{GitflowType.name(type)}\//, '')
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      git = GitOperator.new
      if !File.exist? module_full_path
        Logger.default("No local repository for module '#{module_name}', clone it...")
        module_git = BigkeeperParser.module_git(module_name)
        git.clone(File.expand_path("#{module_full_path}/../"), module_git)
      end

      current_branch_name = git.current_branch(module_full_path)
      if current_branch_name != home_branch_name
        # stash current branch
        StashService.new.stash(module_full_path, current_branch_name, module_name)

        GitService.new.start(module_full_path, name, type)

        StashService.new.pop_stash(module_full_path, home_branch_name, module_name)
      end
    end

    def push(path, user, module_name, home_branch_name, type, comment)
      Logger.highlight("Push branch '#{home_branch_name}' for module '#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      GitService.new.verify_push(module_full_path, comment, home_branch_name, module_name)
    end

    def rebase(path, user, module_name, home_branch_name, type)
      Logger.highlight("Rebase '#{GitflowType.base_branch(type)}' "\
        "to branch '#{home_branch_name}' for module "\
        "'#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      Logger.error("You have some changes in branch "\
        "'#{home_branch_name}' for module '#{module_name}'. "\
        "Use 'push' first please") if GitOperator.new.has_changes(module_full_path)

      GitService.new.verify_rebase(module_full_path, GitflowType.base_branch(type), module_name)
    end

    def pull(path, user, module_name, home_branch_name, type)
      Logger.highlight("Pull branch '#{home_branch_name}' for module '#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      GitOperator.new.pull(module_full_path)
    end

    def switch_to(path, user, module_name, home_branch_name, type)
      Logger.highlight("Switch to branch '#{home_branch_name}' for module '#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)
    end

    def publish(path, user, module_name, home_branch_name, type)
      Logger.highlight("Publish branch '#{home_branch_name}' for module '#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      GitService.new.verify_push(module_full_path, "publish branch #{home_branch_name}", home_branch_name, module_name)
      GitService.new.verify_rebase(module_full_path, GitflowType.base_branch(type), module_name)

      `open #{BigkeeperParser.module_pulls(module_name)}`

      ModuleCacheOperator.new(path).del_branch_module(module_name)
    end

    def finish(path, user, module_name, home_branch_name, type)
      Logger.highlight("Finish branch '#{home_branch_name}' for module '#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      GitService.new.verify_push(module_full_path, "finish branch #{home_branch_name}", home_branch_name, module_name)

      module_git = BigkeeperParser.module_git(module_name)

      DepService.dep_operator(path, user).update_module_config(
                                           module_name,
                                           ModuleType::GIT,
                                           GitInfo.new(module_git, GitType::BRANCH, home_branch_name))

      ModuleCacheOperator.new(path).add_branch_module(module_name)
    end

    def add(path, user, module_name, name, type)
      home_branch_name = "#{GitflowType.name(type)}/#{name}"
      Logger.highlight("Add branch '#{home_branch_name}' for module '#{module_name}'...")


      verify_module(path, user, module_name, home_branch_name, type)

      module_path = BigkeeperParser.module_path(user, module_name)
      DepService.dep_operator(path, user).update_module_config(
                                           module_name,
                                           ModuleType::PATH,
                                           module_path)

      ModuleCacheOperator.new(path).add_path_module(module_name)
    end

    def del(path, user, module_name, name, type)
      home_branch_name = "#{GitflowType.name(type)}/#{name}"

      Logger.highlight("Delete branch '#{home_branch_name}' for module '#{module_name}'...")

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      StashService.new.stash(module_full_path, home_branch_name, module_name)

      GitOperator.new.checkout(module_full_path, GitflowType.base_branch(type))
      # GitOperator.new.del(module_full_path, home_branch_name)

      module_git = BigkeeperParser.module_git(module_name)
      DepService.dep_operator(path, user).update_module_config(
                                           module_name,
                                           ModuleType::GIT,
                                           GitInfo.new(module_git, GitType::BRANCH, GitflowType.base_branch(type)))

      ModuleCacheOperator.new(path).del_path_module(module_name)
    end

    def list(path, user, module_path)
      branches_name = []
      IO.popen("cd #{path}; git branch -a") do |io|
        io.each do |line|
          branches_name << line.strip if line.include? 'feature'
        end
      end
      branches_name
    end
  end
end
