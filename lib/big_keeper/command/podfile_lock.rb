
require 'big_keeper/util/podfile_detector'
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/model/podfile_type'

module BigKeeper

  def self.podfile_detect(path)
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      # Get modulars' name
      modular_list = BigkeeperParser.module_names
      # initialize PodfileDetector
      detector = PodfileDetector.new(path,modular_list)
      # Get unlocked third party pods list
      unlock_pod_list = detector.get_unlock_pod_list
      # Print out unlock pod list
      unlock_pod_list.each do |pod_name|
        p " #{pod_name} should be locked."
      end

  end

  def self.podfile_lock(path)
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      # Get modulars' name
      modular_list = BigkeeperParser.module_names
      # initialize PodfileDetector
      detector = PodfileDetector.new(path,modular_list)
      # Get unlocked third party pods list
      unlock_pod_list = detector.get_unlock_pod_list
      # Get Version
      dictionary = detector.deal_lock_file(path,unlock_pod_list)
      p dictionary
      PodfileOperator.new.find_and_lock("#{path}/Podfile",dictionary)

  end

end
