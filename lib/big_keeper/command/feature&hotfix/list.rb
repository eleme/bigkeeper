#!/usr/bin/ruby
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/list_generator'
require 'big_keeper/service/module_service'


module BigKeeper
  def self.list(path, user, type, options)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    home_path = File.expand_path(path)
    #get home project branches
    branches = GitService.new.branchs_with_type(home_path, type)
    #get modules list
    is_print_log = false if options[:json]
    #get search version
    version = options[:version]
    cache_path = File.expand_path("#{path}/.bigkeeper")
    json_path = "#{cache_path}/branches.json"
    begin
      #get cache file path
      FileUtils.mkdir_p(cache_path) unless File.exist?(cache_path)
      file = File.new(json_path, 'w')
      begin
        #get all modules info
        module_list_dic = get_module_info(path, user, type, version, branches)
        file << module_list_dic.to_json
        file.close
      end
      #print list
      generate_list_with_option(options, json_path, version, branches)
    ensure
      file.close
    end
  end

  def self.get_module_info(path, user, type, version, home_branches)
    #get module list
    modules = BigkeeperParser.module_names
    git_operator = GitOperator.new
    module_info_list = []
    modules.each do |module_name|
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      #local project verify
      if !File.exist? module_full_path
        Logger.default("No local repository for module '#{module_name}', clone it...") if is_print_log
        module_git = BigkeeperParser.module_git(module_name)
        git_operator.clone(File.expand_path("#{module_full_path}/../"), module_git)
      end
      #每个模块详细信息
      module_branch_info = ModuleService.new.module_info(module_full_path, home_branches, user, type, module_name, version)
      module_info_list << module_branch_info
    end
    module_info_list
  end

  def self.generate_list_with_option(options, file_path, version, home_branches)
    if options[:json]
        ListGenerator.generate_json(file_path, home_branches, version)
    else
        ListGenerator.generate_tree(file_path, home_branches, version)
    end
  end
end
