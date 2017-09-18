#!/usr/bin/ruby

require '../util/param_parser'
require '../util/podfile_operator'
require '../util/gitflow_operator'

params = ParamParser.start_new_feature_parser

matched = PodfileOperator.find(params[:main_path] + 'Podfile',
                               '\'' + params[:module_name] + '\'')
if matched
  # 主工程 feature
  GitflowOperator.create_feature(params[:main_path], params[:feature_name])
  # Module feature
  GitflowOperator.create_feature(params[:module_path],params[:feature_name])

  PodfileOperator.find_and_replace(params[:main_path] + 'Podfile',
                                   '\'' + params[:module_name] + '\'',
                                   'pod \'' + params[:module_name] + '\', :path => \'' + params[:module_path]+'\'')

  puts `LANG=en_US.UTF-8 pod install --project-directory=/Users/mmoaay/Documents/eleme/LPDEngineeringAutomation/Example/`# + params[:main_path]
else
  raise params[:module_name]+' not found'
end

IO.popen('open ' + params[:main_path] + '*.xcworkspace') { |f| puts f.gets }
