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

  def self.publish(path, user, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      branch_name = GitOperator.new.current_branch(path)
      Logger.error("Not a #{GitflowType.name(type)} branch, exit.") unless branch_name.include? GitflowType.name(type)

      path_modules = ModuleCacheOperator.new(path).current_path_modules
      Logger.error("You have unfinished modules #{path_modules}, Use 'finish' first please.") unless path_modules.empty?

      ModuleCacheOperator.new(path).cache_git_modules([])

      modules = ModuleCacheOperator.new(path).current_git_modules

      # Rebase modules and modify podfile as git
      modules.each do |module_name|
        ModuleService.new.publish(path, user, module_name, branch_name, type)
      end

      Logger.highlight("Publish branch '#{branch_name}' for 'Home'")

      # pod install
      DepService.dep_operator(path, user).install(false)

      # Recover podfile
      DepService.dep_operator(path, user).recover

      # Push home changes to remote
      GitService.new.verify_push(path, "publish branch #{branch_name}", branch_name, 'Home')

      # Rebase Home
      GitService.new.verify_rebase(path, GitflowType.base_branch(type), 'Home')

      `open #{BigkeeperParser.home_pulls()}`
    ensure
    end
  end
end
