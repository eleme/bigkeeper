require 'big_keeper/util/logger'

module BigKeeper
  class XcodeOperator
    def self.open_workspace(path)
      # Open home workspace
      `open #{path}/*.xcworkspace`
    end
  end
end
