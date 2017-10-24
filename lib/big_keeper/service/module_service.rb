
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

    def finish(path, user, module_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      p module_full_path
      GitOperator.new.git_rebase(module_full_path, 'develop')

      module_pulls = BigkeeperParser.module_pulls(module_name)
      p module_pulls
      `open #{module_pulls}`

      module_git = BigkeeperParser.module_git(module_name)
      PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                           %Q('#{module_name}'),
                                           ModuleType::GIT,
                                           GitInfo.new(module_git, GitType::BRANCH, 'develop'))
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