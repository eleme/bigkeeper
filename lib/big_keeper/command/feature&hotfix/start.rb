#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'

require 'big_keeper/model/podfile_type'

require 'big_keeper/service/stash_service'
require 'big_keeper/service/module_service'


module BigKeeper
  def self.start(path, version, user, name, modules, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      full_name = "#{version}_#{user}_#{name}"
      branch_name = "#{GitflowType.name(type)}/#{full_name}"

      GitService.new.verify_branch(path, branch_name, OperateType::START)

      stash_modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                BigkeeperParser.module_names, ModuleType::PATH)

      # Stash current branch
      StashService.new.stash_all(path, branch_name, user, stash_modules)

      # Handle modules
      if modules
        # Verify input modules
        BigkeeperParser.verify_modules(modules)
      else
        # Get all modules if not specified
        modules = BigkeeperParser.module_names
      end

      Logger.highlight("Add branch '#{branch_name}' for 'Home'...")
      # Start home feature
      GitService.new.start(path, full_name, type)

      # Modify podfile as path and Start modules feature
      modules.each do |module_name|
        ModuleService.new.add(path, user, module_name, full_name, type)
      end

      # pod install
      PodOperator.pod_install(path)

      # Push home changes to remote
      GitService.new.verify_push(path, "init #{GitflowType.name(type)} #{full_name}", branch_name, 'Home')

      # Open home workspace
      `open #{path}/*.xcworkspace`
    ensure
    end
  end
end
