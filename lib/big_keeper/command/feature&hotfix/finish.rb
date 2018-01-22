#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'
require 'big_keeper/util/xcode_operator'
require 'big_keeper/util/bigkeeper_parser'

require 'big_keeper/dependency/dep_service'

require 'big_keeper/model/podfile_type'


module BigKeeper

  def self.finish(path, user, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      modules = DepService.dep_operator(path).modules_with_type(BigkeeperParser.module_names,
        ModuleType::PATH)
      branch_name = GitOperator.new.current_branch(path)

      Logger.error("Not a #{GitflowType.name(type)} branch, exit.") unless branch_name.include? GitflowType.name(type)

      # Rebase modules and modify podfile as git
      modules.each do |module_name|
        ModuleService.new.finish(path, user, module_name, branch_name, type)
      end

      Logger.highlight("Finish branch '#{branch_name}' for 'Home'")

      # pod install
      DepService.dep_operator(path).install(false)

      modules.each do |module_name|
        module_git = BigkeeperParser.module_git(module_name)
        DepService.dep_operator(path).find_and_replace(
                                             module_name,
                                             ModuleType::GIT,
                                             GitInfo.new(module_git, GitType::BRANCH, GitflowType.base_branch(type)))
      end

      # Open home workspace
      DepService.dep_operator(path).open

      # Push home changes to remote
      GitService.new.verify_push(path, "finish branch #{branch_name}", branch_name, 'Home')

      # Rebase Home
      GitService.new.verify_rebase(path, GitflowType.base_branch(type), 'Home')

      `open #{BigkeeperParser.home_pulls()}`
    ensure
    end
  end
end
