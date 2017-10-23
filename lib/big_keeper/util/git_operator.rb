module BigKeeper
  # Operator for got
  class GitOperator
    def current_branch(path)
      Dir.chdir(path) do
        `git rev-parse --abbrev-ref HEAD`.chop
      end
    end

    def user
      `git config user.name`.chop
    end
  end

  # p GitOperator.new.user
  # BigStash::StashOperator.new("/Users/mmoaay/Documents/eleme/BigKeeperMain").list
end
