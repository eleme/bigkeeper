#!/usr/bin/ruby

require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/model/podfile_type'

module BigKeeper
  def self.start_new_feature(path, user, name, modules)
    main_path = File.expand_path(path)
    BigkeeperParser.parse(main_path)

    p modules

    feature_name = "#{BigkeeperParser.version}_#{user}_#{name}"
    p feature_name
  end

  def self.start_home_feature(main_path, feature_name)
  end
  # params = ParamParser.new.start_new_feature_parser
  #
  # main_path = File.expand_path(params[:main_path])
  # module_path = File.expand_path(params[:module_path])
  # module_name = params[:module_name]
  # feature_name = params[:feature_name]
  #
  # matched = PodfileOperator.new.has(%Q(#{main_path}/Podfile), %Q('#{module_name}'))
  #
  # raise module_name + ' not found' unless matched
  #
  # # 主工程 feature
  # GitflowOperator.new.start_feature(main_path, feature_name)
  # # Module feature
  # GitflowOperator.new.start_feature(module_path, feature_name)
  #
  # PodfileOperator.new.find_and_replace(%Q(#{main_path}/Podfile),
  #                                      %Q('#{module_name}'),
  #                                      ModuleType::PATH,
  #                                      module_path)
  #
  # p `pod install --project-directory=#{main_path}`
  # p `open #{main_path}/*.xcworkspace`
end
