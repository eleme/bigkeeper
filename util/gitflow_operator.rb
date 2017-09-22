
# Operator for gitflow
class GitflowOperator
  def create_feature(path, feature_name)
    p `cd #{path}; git flow feature start #{feature_name}`
  end
end
