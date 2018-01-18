require 'big_keeper/util/logger'

module BigKeeper
  class XcodeOperator
    def self.open_workspace(path)
      # Close Xcode
      `pkill Xcode`

      # Open home workspace
      `open #{path}/*.xcworkspace`
    end
  end
end
