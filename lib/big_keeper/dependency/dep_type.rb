require 'big_keeper/dependency/dep_operator'
require 'big_keeper/dependency/dep_pod_operator'
require 'big_keeper/dependency/dep_gradle_operator'
require 'big_keeper/util/file_operator'

module BigKeeper
  module DepType
    NONE = 0
    COCOAPODS = 1
    GRADLE = 2

    def self.type(path)
      if FileOperator.definitely_exists?("#{path}/Podfile")
        COCOAPODS
      elsif FileOperator.definitely_exists?("#{path}/build.gradle")
        GRADLE
      else
        NONE
      end
    end

    def self.operator(path)
      operator_type = type(path)
      if COCOAPODS == operator_type
        DepPodOperator.new(path)
      elsif GRADLE == operator_type
        DepGradleOperator.new(path)
      else
        DepOperator.new(path)
      end
    end
  end

  module ModuleType
    PATH = 1
    GIT = 2
    SPEC = 3
  end

  module GitType
    MASTER = 1
    BRANCH = 2
    TAG = 3
    COMMIT = 4
  end

  class GitInfo
    def initialize(base, type, addition)
      @base, @type, @addition = base, type, addition
    end

    def type
      @type
    end

    def base
      @base
    end

    def addition
      @addition
    end
  end
end
