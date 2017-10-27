require './big_keeper/service/git_service'

module BigKeeper
  # Operator for got
  class ModuleService
    def add(path, user, module_name, name, type)
      branch_name = "#{GitflowType.name(type)}/#{name}"
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      GitflowOperator.new.start(module_full_path, name, type)
      GitOperator.new.push(module_full_path, branch_name)

      module_path = BigkeeperParser.module_path(user, module_name)
      PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                           %('#{module_name}'),
                                           ModuleType::PATH,
                                           module_path)
    end

    def pull(path, user, module_name, branch_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      if !File.exist? module_full_path
        module_git = BigkeeperParser.module_git(module_name)
        GitOperator.new.clone(File.expand_path("#{module_full_path}/../"), module_git)
        GitOperator.new.git_checkout(module_full_path, branch_name)
      else
        p "Start pulling #{module_name}..."
        module_branch_name = GitOperator.new.current_branch(module_full_path)
        GitOperator.new.pull(module_full_path, module_branch_name)
        p "Finish pulling #{module_name}..."
      end
    end

    def finish(path, user, module_name)
      module_git = BigkeeperParser.module_git(module_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      branch_name = GitOperator.new.current_branch(module_full_path)

      PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                           %Q('#{module_name}'),
                                           ModuleType::GIT,
                                           GitInfo.new(module_git, GitType::BRANCH, branch_name))

      GitService.new.verify_rebase(module_full_path, 'develop', module_name)

      `open #{BigkeeperParser.module_pulls(module_name)}`
    end

    def del(path, user, module_name, name, type)
      branch_name = "#{GitflowType.name(type)}/#{name}"
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      GitOperator.new.del(module_full_path, branch_name)
      GitOperator.new.push(module_full_path, branch_name)

      module_git = BigkeeperParser.module_git(module_name)

      PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                           %Q('#{module_name}'),
                                           ModuleType::GIT,
                                           GitInfo.new(module_git, GitType::BRANCH, 'develop'))
    end
  end
end
