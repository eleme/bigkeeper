
# Operator for gitflow
class GitflowOperator
  def create_feature(path, feature_name)
    IO.popen('cd ' + path + '; git flow feature start ' + feature_name) { |f| puts f.gets }
  end
end
