#!/usr/bin/ruby
require 'big_stash/stash_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'
require 'big_keeper/util/xcode_operator'

require 'big_keeper/dependency/dep_service'

module BigKeeper
  def self.switch_to(path, version, user, full_name, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      branch_name = "#{GitflowType.name(type)}/#{full_name}"

      GitService.new.verify_home_branch(path, branch_name, OperateType::SWITCH)

      stash_modules = ModuleCacheOperator.new(path).all_path_modules

      # Stash current branch
      StashService.new.stash_all(path, branch_name, user, stash_modules)

      # Switch to new feature
      GitOperator.new.checkout(path, branch_name)
      GitOperator.new.pull(path)

      # Apply home stash
      StashService.new.pop_stash(path, branch_name, 'Home')

      modules = ModuleCacheOperator.new(path).all_path_modules

      modules.each do |module_name|
        ModuleService.new.switch_to(path, user, module_name, branch_name, type)
      end

      # Install
      DepService.dep_operator(path, user).install(false)

      # Open home workspace
      DepService.dep_operator(path, user).open
    ensure
    end
  end
end
