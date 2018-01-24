#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'
require 'big_keeper/util/xcode_operator'
require 'big_keeper/util/bigkeeper_parser'

require 'big_keeper/dependency/dep_service'

require 'big_keeper/model/podfile_type'


module BigKeeper

  def self.publish(path, user, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      branch_name = GitOperator.new.current_branch(path)
      Logger.error("Not a #{GitflowType.name(type)} branch, exit.") unless branch_name.include? GitflowType.name(type)

      path_modules = DepService.dep_operator(path).modules_with_type(BigkeeperParser.module_names,
        ModuleType::PATH)
      Logger.error("You have unfinished modules #{path_modules}, Use 'finish' first please.") unless path_modules.empty?

      modules = DepService.dep_operator(path).modules_with_branch(BigkeeperParser.module_names,
        branch_name)
      # Rebase modules and modify podfile as git
      modules.each do |module_name|
        ModuleService.new.publish(path, user, module_name, branch_name, type)
      end

      Logger.highlight("Publish branch '#{branch_name}' for 'Home'")

      # pod install
      DepService.dep_operator(path).install(false)

      # Recover podfile
      DepService.dep_operator(path).recover

      # Push home changes to remote
      GitService.new.verify_push(path, "publish branch #{branch_name}", branch_name, 'Home')

      # Rebase Home
      GitService.new.verify_rebase(path, GitflowType.base_branch(type), 'Home')

      `open #{BigkeeperParser.home_pulls()}`
    ensure
    end
  end
end
