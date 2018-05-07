require 'big_keeper/util/podfile_detector'
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/podfile_module'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/logger'

module BigKeeper

  def self.podfile_detect(path)
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      # Get modules' name
      module_list = BigkeeperParser.module_names
      # initialize PodfileDetector
      detector = PodfileDetector.new(path, module_list)
      # Get unlocked third party pods list
      unlock_pod_list = detector.get_unlock_pod_list
      # Print out unlock pod list
      unlock_pod_list.each do |pod_name|
        Logger.default("#{pod_name} should be locked.")
      end
      Logger.separator

  end

  def self.podfile_lock(path)
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      # Get modules' name
      module_list = BigkeeperParser.module_names
      # initialize PodfileDetector
      detector = PodfileDetector.new(path, module_list)
      # Get unlocked third party pods list
      unlock_pod_list = detector.get_unlock_pod_list
      # Get Version
      dictionary = detector.deal_lock_file(path, unlock_pod_list)
      if dictionary.empty?
        Logger.warning("There is nothing to be locked.")
      else
        PodfileOperator.new.find_and_lock("#{path}/Podfile", dictionary)
        Logger.highlight("The Podfile has been changed.")
        Logger.separator
      end



  end

  def self.podfile_modules_update(path)
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      # Get modules' name
      module_list = BigkeeperParser.module_names
      # initialize PodfileDetector
      detector = PodfileModuleDetector.new(path)
      # Get module latest version
      module_dictionary = detector.check_version_list
      # Check if anything should be upgrade
      if module_dictionary.empty?
        Logger.warning("There is nothing to be upgrade.")
      else
        PodfileOperator.new.find_and_upgrade("#{path}/Podfile", module_dictionary)
        Logger.highlight("The Podfile has been changed.")
      end
  end

end
