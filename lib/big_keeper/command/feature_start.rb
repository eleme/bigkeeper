#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/util/bigkeeper_parser'

require 'big_keeper/model/podfile_type'

require 'big_keeper/service/stash_service'
require 'big_keeper/service/module_service'


module BigKeeper
  def self.feature_start(path, version, user, name, modules)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      feature_name = "#{version}_#{user}_#{name}"
      branch_name = "#{GitflowType.name(GitflowType::FEATURE)}/#{feature_name}"

      GitService.new.verify_branch(path, branch_name, OperateType::START)

      stash_modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                BigkeeperParser.module_names, ModuleType::PATH)

      # Stash current branch
      StashService.new.stash(path, branch_name, user, stash_modules)

      # Handle modules
      if modules
        # Verify input modules
        BigkeeperParser.verify_modules(modules)
      else
        # Get all modules if not specified
        modules = BigkeeperParser.module_names
      end

      # Start home feature
      GitService.new.start(path, feature_name, GitflowType::FEATURE)

      # Modify podfile as path and Start modules feature
      modules.each do |module_name|
        ModuleService.new.add(path, user, module_name, feature_name, GitflowType::FEATURE)
      end

      # pod install
      p `pod install --project-directory=#{path}`

      # Push home changes to remote
      GitOperator.new.commit(path, "init #{GitflowType.name(GitflowType::FEATURE)} #{feature_name}")
      GitOperator.new.push(path, branch_name)

      # Open home workspace
      `open #{path}/*.xcworkspace`
    ensure
    end
  end
end
