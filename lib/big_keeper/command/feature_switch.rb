#!/usr/bin/ruby

require '../util/param_parser'
require '../util/podfile_operator'
require '../model/podfile_type'

module BigKeeper
  module BigKeeper
    def self.feature_switch(path, version, user, name)
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      feature_name = "#{version}_#{user}_#{name}"
      branch_name = "#{GitflowType.name(GitflowType::FEATURE)}/#{feature_name}"

      GitService.new.verify_branch(path, branch_name, OperateType::SWITCH)

      modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                BigkeeperParser.module_names, ModuleType::PATH)

      # Stash current branch
      StashService.new.stash(path, branch_name, user, modules)

      # Start home feature
      GitflowOperator.new.start(path, feature_name, GitflowType::FEATURE)

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
      p `open #{path}/*.xcworkspace`
    ensure
    end
  end

  params = ParamParser.new.switch_to_debug_parser

  main_path = File.expand_path(params[:main_path])
  module_path = File.expand_path(params[:module_path])
  module_name = params[:module_name]

  matched = PodfileOperator.new.has(%Q(#{main_path}/Podfile), %Q('#{module_name}'))
  raise module_name + ' not found' unless matched

  PodfileOperator.new.find_and_replace(%Q(#{main_path}/Podfile),
                                       %Q('#{module_name}'),
                                       ModuleType::PATH,
                                       module_path)

  p `pod install --project-directory=#{main_path}`
  p `open #{main_path}/*.xcworkspace`
end
