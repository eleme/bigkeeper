
require './big_keeper/util/podfile_detector'
require './big_keeper/util/gitflow_operator'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/model/podfile_type'

module BigKeeper
  def self.podfile_lock(path)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      unlock_pod_list = PodfileDetector.new.get_unlock_pod_list
      p unlock_pod_list
    end
  end
end
