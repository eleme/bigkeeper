#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'

require 'big_keeper/dependency/dep_service'

require 'big_keeper/dependency/dep_type'

require 'big_keeper/service/stash_service'
require 'big_keeper/service/module_service'


module BigKeeper
  def self.list(path,user)
    begin
      #获得模块列表
      BigkeeperParser.parse("#{path}/Bigkeeper")
      modules = BigkeeperParser.module_names
      p path
      file = File.new("#{path}/.bigkeeper/feature_list", 'w')
      begin
        #进入当前模块 读取git branch 信息
        git_operator = GitOperator.new
        modules.each do |module_name|
          #获得具体全名路径
          module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
          #判断本地是否存在工程
          if !File.exist? module_full_path
            Logger.default("No local repository for module '#{module_name}', clone it...")
            module_git = BigkeeperParser.module_git(module_name)
            git_operator.clone(File.expand_path("#{module_full_path}/../"), module_git)
          end
          # p module_full_path
          feature_modules_list = ModuleService.new.list(module_full_path, user, module_name)
          file << "#{module_name} - branches\n"
          file << feature_modules_list
          file << "\n\n"
        end
         file.close
      end
    ensure
      file.close
    end
  end
end
