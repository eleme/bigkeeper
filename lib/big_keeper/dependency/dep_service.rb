require 'big_keeper/util/git_operator'
require 'big_keeper/model/gitflow_type'
require 'big_keeper/model/operate_type'
require 'big_keeper/util/logger'
require 'big_keeper/dependency/dep_type'

module BigKeeper
  # Operator for podfile
  class DepService
    def self.dep_operator(path)
      p 'dep_operator'
      DepType.operator(path)
    end
  end
end
