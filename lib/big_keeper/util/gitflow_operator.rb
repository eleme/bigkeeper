require 'big_stash/stash_operator'

module BigKeeper
  # Operator for gitflow
  class GitflowOperator
    def start_feature(path, feature_name)
      Dir.chdir(path) do
        p `git flow feature start #{feature_name}`
      end
    end

    def finish_feature(path, feature_name)
      Dir.chdir(path) do
        p `git flow feature finish #{feature_name}`
      end
    end

    def start_hotfix(path, hotfix_name)
      Dir.chdir(path) do
        p `git flow hotfix start #{hotfix_name}`
      end
    end

    def finish_hotfix(path, hotfix_name)
      Dir.chdir(path) do
        p `git flow hotfix finish #{hotfix_name}`
      end
    end

    def start_release(path, release_name)
      Dir.chdir(path) do
        p `git flow release start #{release_name}`
      end
    end

    def finish_release(path, release_name)
      Dir.chdir(path) do
        p `git flow release finish #{release_name}`
      end
    end

    def stash(path, feature_name)
      BigStash::StashOperator.new(path).stash(feature_name)
    end

    def apply_stash(path, feature_name)
      BigStash::StashOperator.new(path).apply_stash(feature_name)
    end

    def current_branch(path)
      Dir.chdir(path) do
        `git rev-parse --abbrev-ref HEAD`.chop
      end
    end
  end

  # p GitflowOperator.new.current_branch('/Users/mmoaay/Documents/eleme/BigKeeperMain')
end
