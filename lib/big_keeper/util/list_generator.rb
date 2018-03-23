require 'big_keeper/util/logger'

module BigKeeper
  class ListGenerator
    def self.generate(file_path,branches_name)
      module_branches_dic = {}
      home_name = BigkeeperParser.home_name
      File.open(file_path, 'r') do |file|
        file.each_line do |line|
          if /=>/ =~ line.delete('{}"')
            module_branches_dic[$~.pre_match] = $~.post_match.delete('[]"').split(',')
          end
        end
      end

      branches_name.each do |branch_name|
        Logger.highlight(" #{home_name} - #{branch_name} ")
        module_branches_dic.keys.each do |module_name|
          module_branches_dic[module_name].each do |module_branch|
            if module_branch.include?(branch_name.strip.delete('*'))
              Logger.default("   |_ _ _ #{module_name} - #{branch_name}")
                break
            end
          end
        end
      end
    end
  end
end
