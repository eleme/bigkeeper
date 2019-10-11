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

    def pre_publish(path, user, module_name, home_branch_name, type)
      Logger.highlight("Prepare to publish branch '#{home_branch_name}' for module '#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      GitService.new.verify_push(module_full_path, "prepare to rebase '#{GitflowType.base_branch(type)}'", home_branch_name, module_name)
      GitService.new.verify_rebase(module_full_path, GitflowType.base_branch(type), module_name)
    end

    def publish(path, user, module_name, home_branch_name, type)
      Logger.highlight("Publish branch '#{home_branch_name}' for module '#{module_name}'...")

      DepService.dep_operator(path, user).update_module_config(module_name, ModuleOperateType::PUBLISH)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      GitService.new.verify_push(module_full_path, "publish branch #{home_branch_name}", home_branch_name, module_name)

      current_cmd = LeanCloudLogger.instance.command
      cmds = BigkeeperParser.post_install_command

      if cmds && (cmds.keys.include? current_cmd)
        cmd = BigkeeperParser.post_install_command[current_cmd]
        if module_full_path
          Dir.chdir(module_full_path) do
            system cmd
          end
        end
      else
        `open #{BigkeeperParser.module_pulls(module_name)}`
      end

      ModuleCacheOperator.new(path).del_git_module(module_name)
    end

    def finish(path, user, module_name, home_branch_name, type)
      Logger.highlight("Finish branch '#{home_branch_name}' for module '#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)

      DepService.dep_operator(path, user).update_module_config(module_name, ModuleOperateType::FINISH)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      GitService.new.verify_push(module_full_path, "finish branch #{home_branch_name}", home_branch_name, module_name)

      ModuleCacheOperator.new(path).add_git_module(module_name)
      ModuleCacheOperator.new(path).del_path_module(module_name)
    end

    def add(path, user, module_name, name, type)
      home_branch_name = "#{GitflowType.name(type)}/#{name}"
      Logger.highlight("Add branch '#{home_branch_name}' for module '#{module_name}'...")

      verify_module(path, user, module_name, home_branch_name, type)

      DepService.dep_operator(path, user).update_module_config(module_name, ModuleOperateType::ADD)

      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      GitService.new.verify_push(module_full_path, "init #{GitflowType.name(type)} #{name}", home_branch_name, module_name)

      ModuleCacheOperator.new(path).add_path_module(module_name)
    end

    def del(path, user, module_name, name, type)
      home_branch_name = "#{GitflowType.name(type)}/#{name}"

      Logger.highlight("Delete branch '#{home_branch_name}' for module '#{module_name}'...")

      module_git = BigkeeperParser.module_git(module_name)
      DepService.dep_operator(path, user).update_module_config(module_name, ModuleOperateType::DELETE)

      # Stash module current branch
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      current_branch_name = GitOperator.new.current_branch(module_full_path)
      StashService.new.stash(module_full_path, current_branch_name, module_name)
      GitOperator.new.checkout(module_full_path, GitflowType.base_branch(type))

      ModuleCacheOperator.new(path).del_path_module(module_name)
    end

    def module_info(module_path, home_branch_name, user, type, module_name, version)
      result_dic = {}
      matched_branches = []
      branches = GitService.new.branchs_with_type(module_path, type)
      if version == 'all versions'
        matched_branches = branches
      else
        branches.each do | branch |
          matched_branches << branch if branch.include?(version)
        end
      end
      result_dic[:module_name] = module_name
      result_dic[:current_branch] = GitOperator.new.current_branch(module_path)
      result_dic[:branches] = matched_branches
      result_dic
    end

    def release_check_changed(path, user, module_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      git = GitOperator.new
      if !File.exist? module_full_path
        Logger.default("No local repository for module '#{module_name}', clone it...")
        module_git = BigkeeperParser.module_git(module_name)
        git.clone(File.expand_path("#{module_full_path}/../"), module_git)
      end
      GitService.new.verify_checkout_pull(module_full_path, 'develop')
      git.check_remote_branch_diff(module_full_path, 'develop', 'master')
    end

    def release_start(path, user, modules, module_name, version)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      git = GitOperator.new
      if !File.exist? module_full_path
        Logger.default("No local repository for module '#{module_name}', clone it...")
        module_git = BigkeeperParser.module_git(module_name)
        git.clone(File.expand_path("#{module_full_path}/../"), module_git)
      end
      #stash module
      StashService.new.stash(module_full_path, GitOperator.new.current_branch(module_full_path), module_name)
      # delete cache
      CacheOperator.new(module_full_path).clean()
      # checkout develop
      GitService.new.verify_checkout_pull(module_full_path, 'develop')
      DepService.dep_operator(path, user).release_module_start(modules, module_name, version)
    end

    def release_finish(path, user, modules, module_name, version)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      git = GitOperator.new
      if !File.exist? module_full_path
        Logger.default("No local repository for module '#{module_name}', clone it...")
        module_git = BigkeeperParser.module_git(module_name)
        git.clone(File.expand_path("#{module_full_path}/../"), module_git)
      end
      #stash module
      StashService.new.stash(module_full_path, GitOperator.new.current_branch(module_full_path), module_name)
      # delete cache
      CacheOperator.new(module_full_path).clean()
      # checkout develop
      GitService.new.verify_checkout_pull(module_full_path, 'develop')
      DepService.dep_operator(path, user).release_module_finish(modules, module_name, version)

      # Push home changes to remote
      Logger.highlight("Push branch 'develop' for #{module_name}...")
      GitService.new.verify_push(
        module_full_path,
        "release finish for #{version}",
        'develop',
        "#{module_name}")
    end

    private :verify_module
  end
end
