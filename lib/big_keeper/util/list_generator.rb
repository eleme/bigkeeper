require 'big_keeper/util/logger'
require 'json'

module BigKeeper
  class ListGenerator
    #generate tree print throught console
    def self.generate_tree(file_path, branches_name, version)
      module_branches_dic = {}
      json_data = File.read(file_path)
      dic = JSON.parse(json_data)
      dic.keys.select do |module_name|
          module_branches_dic[module_name] = dic[module_name]
      end
      to_tree(module_branches_dic, branches_name, version)
    end

      #generate json print throught console
    def self.generate_json(file_path, branches, version)
      to_json(file_path, branches)
    end

    def self.to_json(file_path, branches_name)
      branches_dic = {}
      dic = JSON.parse(File.read(file_path))
      dic.keys.select do  |module_name|
        branches_dic[module_name] = dic[module_name] unless dic[module_name].empty?
      end
      Logger.default(JSON.pretty_generate(branches_dic))
    end

    def self.to_tree(module_branches_dic, branches_name, version)
      home_name = BigkeeperParser.home_name
      print_all = version == "all versions"
      branches_name.each do |branch_name|
        next unless branch_name.include?(version) || print_all
        Logger.highlight(branch_name.strip)
        module_branches_dic.keys.each do |module_name|
          module_branches_dic[module_name].each do |module_branch|
            if module_branch.include?(branch_name.strip.delete('*'))
              Logger.default("   ├── #{module_name} - #{branch_name.strip}")
                break
            end
          end
        end
      end
    end
  end
end
