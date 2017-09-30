require 'big_stash'

module BigKeeper
  # Operator for gitflow
  class GitflowOperator
    def start_feature(path, feature_name)
      p `cd #{path}; git flow feature start #{feature_name}`
    end

    def finish_feature(path, feature_name)
      p `cd #{path}; git flow feature finish #{feature_name}`
    end

    def start_hotfix(path, hotfix_name)
      p `cd #{path}; git flow hotfix start #{hotfix_name}`
    end

    def finish_hotfix(path, hotfix_name)
      p `cd #{path}; git flow hotfix finish #{hotfix_name}`
    end

    def start_release(path, release_name)
      p `cd #{path}; git flow release start #{release_name}`
    end

    def finish_release(path, release_name)
      p `cd #{path}; git flow release finish #{release_name}`
    end

    def stash(path, feature_name)
      BigStash::StashOperator.new(path).stash(feature_name)
    end

    def apply_stash(path, feature_name)
      BigStash::StashOperator.new(path).apply_stash(feature_name)
    end
  end
end
