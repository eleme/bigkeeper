require 'big_keeper/util/logger'

module BigKeeper
  class XcodeOperator
    def self.open_workspace(path)
      # Close Xcode
      `pkill Xcode`

      sleep 0.5

      # Open home workspace
      `open #{path}/*.xcworkspace`
    end
  end
end
