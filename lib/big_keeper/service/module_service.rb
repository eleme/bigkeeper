require 'big_keeper/service/git_service'

module BigKeeper
  # Operator for got
  class ModuleService
    def pull(path, user, module_name, branch_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      if !File.exist? module_full_path
        module_git = BigkeeperParser.module_git(module_name)
        GitOperator.new.clone(File.expand_path("#{module_full_path}/../"), module_git)
        GitOperator.new.git_checkout(module_full_path, branch_name)
      else
        module_branch_name = GitOperator.new.current_branch(module_full_path)
        if module_branch_name != branch_name
          p "Current branch of #{module_name} is #{module_branch_name},\
            stash it and checkout #{branch_name}..."
          BigStash::StashOperator.new(module_full_path).stash(module_branch_name)
          GitOperator.new.git_checkout(module_full_path, branch_name)
        end
        p "Start pulling #{module_name}..."
        GitOperator.new.pull(module_full_path, branch_name)
        p "Finish pulling #{module_name}..."
      end
    end

    def switch(path, user, module_name, branch_name)
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      p "Start switching #{module_name}..."
      if !File.exist? module_full_path
        module_git = BigkeeperParser.module_git(module_name)
        GitOperator.new.clone(File.expand_path("#{module_full_path}/../"), module_git)
        GitOperator.new.git_checkout(module_full_path, branch_name)
      else
        GitOperator.new.git_checkout(module_full_path, branch_name)
        GitOperator.new.pull(module_full_path, branch_name)
      end
      p "Finish switching #{module_name}..."
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

    def del(path, user, module_name, name, type)
      branch_name = "#{GitflowType.name(type)}/#{name}"
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

      GitOperator.new.git_checkout(module_full_path, 'develop')
      GitOperator.new.del(module_full_path, branch_name)

      module_git = BigkeeperParser.module_git(module_name)

      PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                           %Q('#{module_name}'),
                                           ModuleType::GIT,
                                           GitInfo.new(module_git, GitType::BRANCH, 'develop'))
    end
  end
end
