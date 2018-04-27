#!/usr/bin/ruby
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/list_generator'
require 'big_keeper/service/module_service'


module BigKeeper
  def self.list(path,user,type,options)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    #get home project branches
    branches = GitService.new.branchs_with_type(File.expand_path(path), type)
    #get modules list
    begin
      modules = BigkeeperParser.module_names
      cache_path = File.expand_path("#{path}/.bigkeeper")
      version = options[:version]
      FileUtils.mkdir_p(cache_path) unless File.exist?(cache_path)
      file = File.new("#{cache_path}/feature_list", 'w')
      begin
        #read git info
        git_operator = GitOperator.new
        module_list_dic = {}
        modules.each do |module_name|
          module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
          #local project verify
          if !File.exist? module_full_path
            Logger.default("No local repository for module '#{module_name}', clone it...")
            module_git = BigkeeperParser.module_git(module_name)
            git_operator.clone(File.expand_path("#{module_full_path}/../"), module_git)
          end
          feature_modules_list = ModuleService.new.list(module_full_path, user,type, module_name,version)
          module_list_dic[module_name] = feature_modules_list
        end
        file << module_list_dic.to_json
        file.close
      end
      #print list
      if options[:json]
          ListGenerator.generate_json(file, branches,version)
      else
          ListGenerator.generate_tree(file, branches,version)
      end
    ensure
      file.close
    end
  end
end
