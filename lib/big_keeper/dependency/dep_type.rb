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
      if !FileOperator.definitely_exists?("#{path}/Podfile")
        p 'cocoapods'
        COCOAPODS
      elsif !FileOperator.definitely_exists?("#{path}/build.gradle")
        GRADLE
      else
        NONE
      end
    end

    def self.operator(type)
      if COCOAPODS == type
        DepPodOperator.new
      elsif GRADLE == type
        DepGradleOperator.new
      else
        DepOperator.new
      end
    end
  end
end
