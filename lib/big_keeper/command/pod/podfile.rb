require 'big_keeper/util/podfile_detector'
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/podfile_module'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/logger'
require 'big_keeper/util/lockfile_parser'

module BigKeeper

  def self.podfile_detect(path)
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      # Get modules' name
      # module_list = BigkeeperParser.module_names
      # initialize PodfileDetector
      detector = PodfileParser.instance
      detactor.parse
      # Get unlocked third party pods list
      unlock_pod_list = detector.get_unlock_pod_list
      # Print out unlock pod list
      unlock_pod_list.each do |pod_name|
        Logger.default("#{pod_name} should be locked.")
      end
      Logger.separator

  end

  def self.podfile_lock(path, is_all)
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      # initialize PodfileDetector
      pod_parser = PodfileParser.instance
      #Parser Podfile.lock
      pod_parser.parse(path)
      #initialize LockfileParser
      lock_parser = LockfileParser.instance
      #Parser Podfile.lock
      lock_parser.parse(path)
      # Get unlocked third party pods list
      unlock_pod_info = lock_parser.get_unlock_pod_list(is_all)
      # Lock modules in podfile
      if unlock_pod_info.empty?
        Logger.warning("There is nothing to be locked.")
      else
        PodfileOperator.new.find_and_lock("#{path}/Podfile", unlock_pod_info)
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
