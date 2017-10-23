module BigKeeper
  # Operator for got
  class GitOperator
    def current_branch(path)
      Dir.chdir(path) do
        `git rev-parse --abbrev-ref HEAD`.chop
      end
    end

    def has_branch(path, branch_name)
      has_branch = false
      IO.popen("cd #{path}; git branch -a") do |io|
        io.each do |line|
          has_branch = true if line.include? branch_name
        end
      end
      has_branch
    end

    def git_rebase(path, branch_name)
      Dir.chdir(path) do
        `git rebase #{branch_name}`
      end
    end

    def user
      `git config user.name`.chop
    end
  end

  # p GitOperator.new.user
  # BigStash::StashOperator.new("/Users/mmoaay/Documents/eleme/BigKeeperMain").list
end
