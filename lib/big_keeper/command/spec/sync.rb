require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/logger'
require 'big_keeper/util/podspec_operator'
require 'big_keeper/util/lockfile_parser'

module BigKeeper
  def self.spec_sync(path, user, module_name)
    # Parse Bigkeeper file
    BigkeeperParser.parse("#{path}/Bigkeeper")

    module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

    detector = PodspecOperator.instance
    detector.parse(module_full_path, module_name)

    lock_parser = LockfileParser.instance
    lock_parser.parse(path)

    pod_versions = Hash.new
    for pod in detector.pod_list
      pod_ver = get_pod_version(lock_parser.pods, pod)
      if pod_ver != nil
        pod_versions = pod_versions.merge(pod_ver)
      end
    end

    PodfileOperator.new.find_and_lock("#{module_full_path}/Example/Podfile", pod_versions)
    Logger.highlight("The Podfile has been changed.")
  end

  def self.get_pod_version(locks, pod_name)
    pod_version = Hash.new
    if locks[pod_name]
      pod_version = {"#{pod_name}" => locks[pod_name]}
    end
  end

end
