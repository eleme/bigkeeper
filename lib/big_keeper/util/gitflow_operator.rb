require 'big_stash'

module BigKeeper
  # Operator for gitflow
  class GitflowOperator
    def create_feature(path, feature_name)
      p `cd #{path}; git flow feature start #{feature_name}`
    end

    def stash(path, feature_name)
      BigStash::StashOperator.new(path).stash(feature_name)
    end

    def apply_stash(path, feature_name)
      BigStash::StashOperator.new(path).apply_stash(feature_name)
    end
  end
end
