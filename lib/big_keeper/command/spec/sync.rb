require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/logger'

module BigKeeper
  def self.spec_sync(path, version, user, module_name)
    # Parse Bigkeeper file
    BigkeeperParser.parse("#{path}/Bigkeeper")
    
    Logger.default('Coming soon.')
  end
end
