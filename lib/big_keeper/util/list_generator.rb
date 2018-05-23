require 'big_keeper/util/logger'
require 'json'

module BigKeeper
  class ListGenerator
    #generate tree print throught console
    def self.generate_tree(file_path, home_branches, version)
      module_branches_dic = {}
      json_data = File.read(file_path)
      module_branches_dic = JSON.parse(json_data)
      to_tree(module_branches_dic, home_branches, version)
      File.delete(file_path)
    end

      #generate json print throught console
    def self.generate_json(file_path, home_branches, version)
      module_branches_dic = {}
      json_data = File.read(file_path)
      module_branches_dic = JSON.parse(json_data)
      json = to_json(home_branches, module_branches_dic, version)
      puts JSON.pretty_generate(json)
      File.delete(file_path)
    end

    def self.to_json(home_branches, module_info_list, version)
      json_array = []
      print_all = version == "all versions"
      home_branches.each do | home_branch_name |
          next unless home_branch_name.include?(version) || print_all
          branch_dic = {}
          involve_modules = []
          module_info_list.collect do | module_info_dic |
            next unless module_info_dic["branches"] != nil
            module_name = module_info_dic["module_name"]
            module_info_dic["branches"].each do | module_branch |
              if module_branch.strip.delete("*") == home_branch_name.strip.delete("*")
                module_current_info = {}
                module_current_info["module_name"] = module_name
                module_current_info["current_branch"] = module_info_dic["current_branch"]
                involve_modules << module_current_info
              end
            end
          end

          branch_dic["is_remote"] = false
          branch_dic["is_current"] = false

          if home_branch_name =~ /^remotes\//
            home_branch_name = $~.post_match
            branch_dic["is_remote"] = true
          end

          if home_branch_name =~ /^origin\//
            home_branch_name = $~.post_match
          end

          if home_branch_name.include?("*")
            home_branch_name = home_branch_name.delete("*")
            branch_dic["is_current"] = true
          end

          if home_branch_name =~ /^feature\//
            home_branch_name = $~.post_match
          end

          if home_branch_name =~ /^hotfix\//
            home_branch_name = $~.post_match
          end

          branch_dic["home_branch_name"] = home_branch_name
          branch_dic["involve_modules"] = involve_modules
          json_array << branch_dic
      end
      json_array
    end

    def self.to_tree(module_branches_dic, branches_name, version)
      home_name = BigkeeperParser.home_name
      print_all = version == "all versions"
      branches_name.each do | home_branch_name |
        next unless home_branch_name.include?(version) || print_all
        Logger.highlight(home_branch_name.strip)
        module_branches_dic.each do | module_info_dic |
          module_name = module_info_dic["module_name"]
          next if module_info_dic["branches"] == nil
          module_info_dic["branches"].each do | module_branch |
            if module_branch.include?(home_branch_name.strip.delete('*'))
              if !module_branch.include?("*") && home_branch_name.include?("*")
                Logger.warning("   ├── #{module_name} (current branch :#{module_info_dic["current_branch"]})")
              else
                Logger.default("   ├── #{module_name}")
              end
                break
            end
          end
        end
      end
    end
  end
end
