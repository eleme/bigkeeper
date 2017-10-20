#!/usr/bin/ruby

require '../util/param_parser'
require '../util/podfile_operator'
require '../model/podfile_type'

module BigKeeper
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
