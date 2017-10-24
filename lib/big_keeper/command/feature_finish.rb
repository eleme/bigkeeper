#!/usr/bin/ruby

require './big_keeper/util/podfile_operator'
require './big_keeper/util/bigkeeper_parser'

require './big_keeper/model/podfile_type'

module BigKeeper

  def self.feature_finish(path, user, name)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      modules = PodfileOperator.new.modules_with_type("#{path}/Podfile", BigkeeperParser.module_names, ModuleType::PATH)
      p modules
      # Rebase modules and modify podfile as git
      modules.each do |module_name|
        ModuleService.new.finish(path, user, module_name)
      end

      # # pod install
      # p `pod install --project-directory=#{path}`
      #
      # # Push home changes to remote
      # GitOperator.new.commit(path, "init #{GitflowType.name(GitflowType::FEATURE)} #{feature_name}")
      # GitOperator.new.push(path, branch_name)
    ensure
    end
  end

  # params = ParamParser.new.switch_to_push_parser
  #
  # main_path = File.expand_path(params[:main_path])
  # module_name = params[:module_name]
  # git_base = params[:git_base]
  # feature_name = params[:feature_name]
  #
  # matched = PodfileOperator.new.has(%Q(#{main_path}/Podfile), %Q('#{module_name}'))
  # raise module_name + ' not found' unless matched
  #
  #
  # PodfileOperator.new.find_and_replace(%Q(#{main_path}/Podfile),
  #                                      %Q('#{module_name}'),
  #                                      ModuleType::GIT,
  #                                      GitInfo.new(git_base, GitType::BRANCH, feature_name))
  #
  # p `pod install --project-directory=#{main_path}`
  # p `open #{main_path}/*.xcworkspace`
end
