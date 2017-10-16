#!/usr/bin/ruby
require 'rexml/document'
include REXML

require '../util/param_parser'
require '../util/podfile_operator'
require '../util/gitflow_operator'
require '../model/podfile_type'

# 1.切换主工程的分支到 release分支
# 2.替换当前 podfile 中每个 module 为 pod #{module_name}, :git => '#{source.base}', :tag => '#{source.addition}'
# 3.替换 info.plist 中的 build version

# params = ParamParser.new.start_main_release_parser
#
# main_path = File.expand_path(params[:main_path])
# module_path = File.expand_path(params[:module_path])
# module_name = params[:module_name]
# feature_name = params[:feature_name]
#
# matched = PodfileOperator.new.has(%Q(#{main_path}/Podfile), %Q('#{module_name}'))
# raise module_name + ' not found' unless matched

# step 0
# check git status

# step 1
# PodfileOperator.new
# p %Q(cd #{main_path})
branches = `git branch -a`
puts branches
if branches.include?'release'
	p `git checkout release`
else
	p `git branch -b release`
end

# step 2
# PodfileOperator.new.find_and_replace(%Q(#{main_path}/Podfile),
                                     # %Q('#{module_name}'),
                                     # ModuleType::PATH,
                                     # module_path)

# PodfileOperator.new.replace_all_module_release(%Q(#{main_path}/Podfile,
											  #  module_names,
											  #  GitType::TAG,
											  #  2.8.0))
