require 'big_keeper/util/git_operator'
require 'big_keeper/model/gitflow_type'
require 'big_keeper/model/operate_type'

module BigKeeper
  # Operator for got
  class GitService
    def start(path, name, type)
      if GitOperator.new.has_remote_branch(path, 'master')
        if GitOperator.new.has_local_branch(path, 'master')
          if GitOperator.new.has_commits(path, 'master')
            raise %Q('master' has unpushed commits, you should fix it)
          else
            GitOperator.new.git_checkout(path, 'master')
            GitOperator.new.pull(path, 'master')
          end
        else
          GitOperator.new.git_checkout(path, 'master')
        end
      end

      if GitOperator.new.has_remote_branch(path, 'develop')
        if GitOperator.new.has_local_branch(path, 'develop')
          if GitOperator.new.has_commits(path, 'develop')
            raise %Q('develop' has unpushed commits, you should fix it)
          else
            GitOperator.new.git_checkout(path, 'develop')
            GitOperator.new.pull(path, 'develop')
          end
        else
          GitOperator.new.git_checkout(path, 'develop')
        end
      end

      if !GitflowOperator.new.verify_git_flow(path)
        GitOperator.new.push(path, 'develop') if !GitOperator.new.has_remote_branch(path, 'develop')
        GitOperator.new.push(path, 'master') if !GitOperator.new.has_remote_branch(path, 'master')
      end

      branch_name = "#{GitflowType.name(type)}/#{name}"
      if GitOperator.new.has_branch(path, branch_name)
        GitOperator.new.git_checkout(path, branch_name)
        GitOperator.new.pull(path, branch_name)
      else
        GitflowOperator.new.start(path, name, type)
        GitOperator.new.push(path, branch_name)
      end
    end

    def verify_branch(path, branch_name, type)
      GitOperator.new.git_fetch(path)

      if OperateType::START == type
        if GitOperator.new.current_branch(path) == branch_name
          raise %(Current branch is '#{branch_name}' already. Use 'update' please)
        end
        if GitOperator.new.has_branch(path, branch_name)
          raise %(Branch '#{branch_name}' already exists. Use 'switch' please)
        end
      elsif OperateType::SWITCH == type
        if !GitOperator.new.has_branch(path, branch_name)
          raise %(Can't find a branch named '#{branch_name}'. Use 'start' please)
        end
        if GitOperator.new.current_branch(path) == branch_name
          raise %(Current branch is '#{branch_name}' already. Use 'update' please)
        end
      elsif OperateType::UPDATE == type
        if !GitOperator.new.has_branch(path, branch_name)
          raise %(Can't find a branch named '#{branch_name}'. Use 'start' please)
        end
        if GitOperator.new.current_branch(path) != branch_name
          raise %(Current branch is not '#{branch_name}'. Use 'switch' please)
        end
      else
        raise %(Not a valid command for '#{branch_name}'.)
      end
    end

    def branchs_with_type(path, type)
      branchs = []
      Dir.chdir(path) do
        IO.popen('git branch -a') do |io|
          io.each do |line|
            branchs << line.rstrip if line =~ /(\* |  )#{GitflowType.name(type)}*/
          end
        end
      end
      branchs
    end

    def verify_rebase(path, branch_name, name)
      Dir.chdir(path) do
        IO.popen("git rebase #{branch_name} --ignore-whitespace") do |io|
          unless io.gets
            raise "#{name} is already in a rebase-apply, Please:\n\
                  1.Resolve it;\n\
                  2.Commit the changes;\n\
                  3.Push to remote;\n\
                  4.Create a MR;\n\
                  5.Run 'finish' again."
          end
          io.each do |line|
            next unless line.include? 'Merge conflict'
            raise "Merge conflict in #{name}, Please:\n\
                  1.Resolve it;\n\
                  2.Commit the changes;\n\
                  3.Push to remote;\n\
                  4.Create a MR;\n\
                  5.Run 'finish' again."
          end
        end
        `git push -f origin #{branch_name}`
        GitOperator.new.git_checkout(path, 'develop')
      end
    end
  end
end
