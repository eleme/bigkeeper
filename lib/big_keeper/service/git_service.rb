require './big_keeper/util/git_operator'
require './big_keeper/model/gitflow_type'
require './big_keeper/model/operate_type'

module BigKeeper
  # Operator for got
  class GitService
    def verify_branch(path, branch_name, type)
      GitOperator.new.git_fetch(path)

      if OperateType::START == type
        if GitOperator.new.current_branch(path) == branch_name
          raise %(Current branch is '#{branch_name}' already. Use 'update' please)
        end
        if GitOperator.new.has_branch(path, branch_name)
          raise %(Branch '#{branch_name}' already exists. Use 'switch' please)
        end
      else if OperateType::SWITCH == type
        if !GitOperator.new.has_branch(path, branch_name)
          raise %(Can't find a branch named '#{branch_name}'. Use 'start' please)
        end
        if GitOperator.new.current_branch(path) == branch_name
          raise %(Current branch is '#{branch_name}' already. Use 'update' please)
        end
      else if OperateType::UPDATE == type
      else
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
