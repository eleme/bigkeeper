#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/bigkeeper_parser'

require 'big_keeper/model/podfile_type'

module BigKeeper

  def self.feature_finish(path, user)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                BigkeeperParser.module_names, ModuleType::PATH)

      branch_name = GitOperator.new.current_branch(path)
      raise "Not a feature branch, exit." unless branch_name.include? 'feature'

      # Rebase modules and modify podfile as git
      modules.each do |module_name|
        ModuleService.new.finish(path, user, module_name)
      end

      BigkeeperParser.module_names.each do |module_name|
        module_git = BigkeeperParser.module_git(module_name)
        PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                             %Q('#{module_name}'),
                                             ModuleType::GIT,
                                             GitInfo.new(module_git, GitType::BRANCH, 'develop'))
      end

      # pod install
      p `pod install --project-directory=#{path}`

      # Push home changes to remote
      GitOperator.new.commit(path, "finish #{GitflowType.name(GitflowType::FEATURE)} #{branch_name}")
      GitOperator.new.push(path, branch_name)

      GitService.new.verify_rebase(path, 'develop', 'Home')

      `open #{BigkeeperParser.home_pulls()}`
    ensure
    end
  end
end
