#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'
require 'big_keeper/util/xcode_operator'
require 'big_keeper/util/cache_operator'
require 'big_keeper/util/bigkeeper_parser'

require 'big_keeper/dependency/dep_service'

require 'big_keeper/dependency/dep_type'


module BigKeeper

  def self.finish(path, user, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      branch_name = GitOperator.new.current_branch(path)
      Logger.error("Not a #{GitflowType.name(type)} branch, exit.") unless branch_name.include? GitflowType.name(type)

      modules = ModuleCacheOperator.new(path).current_path_modules

      # Rebase modules and modify module as git
      modules.each do |module_name|
        ModuleService.new.finish(path, user, module_name, branch_name, type)
      end

      Logger.highlight("Finish branch '#{branch_name}' for 'Home'")

      # Install
      DepService.dep_operator(path, user).install(false)

      # Open home workspace
      DepService.dep_operator(path, user).open

      # Push modules changes to remote
      modules = ModuleCacheOperator.new(path).all_path_modules
      modules.each do |module_name|
        ModuleService.new.push(
          path,
          user,
          module_name,
          branch_name,
          type,
          "finish branch #{branch_name}")
      end

      # Delete all path modules and cache git modules
      ModuleCacheOperator.new(path).cache_path_modules([])
      ModuleCacheOperator.new(path).cache_git_modules(modules)

      # Push home changes to remote
      GitService.new.verify_push(path, "finish branch #{branch_name}", branch_name, 'Home')
    ensure
    end
  end
end
