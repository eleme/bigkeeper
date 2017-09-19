#!/usr/bin/ruby

require '../util/param_parser'
require '../util/podfile_operator'
require '../util/gitflow_operator'
require '../model/podfile_type'

params = ParamParser.new.start_new_feature_parser

main_path = File.expand_path(params[:main_path])
module_path = File.expand_path(params[:module_path])
module_name = params[:module_name]
feature_name = params[:feature_name]

matched = PodfileOperator.new.has(%Q(#{main_path}/Podfile), %Q('#{module_name}'))
if matched
  # 主工程 feature
  GitflowOperator.new.create_feature(main_path, feature_name)
  # Module feature
  GitflowOperator.new.create_feature(module_path, feature_name)

  PodfileOperator.new.find_and_replace(%Q(#{main_path}/Podfile), %Q('#{module_name}'), ModuleType::PATH, module_path)

  puts `LANG=en_US.UTF-8 pod install --project-directory=/Users/mmoaay/Documents/eleme/LPDEngineeringAutomation/Example/`# + params[:main_path]
else
  raise module_name + ' not found'
end

IO.popen('open ' + params[:main_path] + '*.xcworkspace') { |f| puts f.gets }
