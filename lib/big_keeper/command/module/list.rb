require 'logger'
require 'json'

module BigKeeper
  def self.module_list(path, user, options)
      BigkeeperParser.parse("#{path}/Bigkeeper")
      module_dic = BigkeeperParser.parse_modules
      module_list = Array.new
      module_dic.keys.each do | key |
        dic = Hash["module_name" => key,
                           "git" => module_dic[key][:git],
                         "pulls" => module_dic[key][:pulls]]
        module_list << dic
      end
      json = JSON.pretty_generate(module_list)
      Logger.default(json)
  end
end
