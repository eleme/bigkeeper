require './big_keeper/util/git_operator'

module BigKeeper
  # Operator for got
  class GitService
    def verify_branch(path, branch_name)
      GitOperator.new.git_fetch(path)

      if GitOperator.new.current_branch(path) == branch_name
        raise %Q(Current branch is '#{branch_name}' already. Use 'update' please)
      end
      if GitOperator.new.has_branch(path, branch_name)
        raise %Q(Branch '#{branch_name}' already exists. Use 'switch' please)
      end
    end

    def verify_rebase(path, branch_name, name)
      Dir.chdir(path) do
        IO.popen("git rebase #{branch_name} --ignore-whitespace") do |io|
          if !io.gets
            raise "#{name} is already in a rebase-apply, Please:\n\
                  1.Resolve it;\n\
                  2.Commit the changes;\n\
                  3.Push to remote;\n\
                  4.Create a MR;\n\
                  5.Run 'finish' again."
          end
          io.each do |line|
            if line.include? 'Merge conflict'
              raise "Merge conflict in #{name}, Please:\n\
                    1.Resolve it;\n\
                    2.Commit the changes;\n\
                    3.Push to remote;\n\
                    4.Create a MR;\n\
                    5.Run 'finish' again."
            end
          end
        end
        `git push -f origin #{branch_name}`
        GitOperator.new.git_checkout(path, 'develop')
      end
    end
  end
end
