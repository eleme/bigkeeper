#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'

require 'big_keeper/dependency/dep_service'

require 'big_keeper/model/podfile_type'

require 'big_keeper/service/stash_service'
require 'big_keeper/service/module_service'


module BigKeeper
  def self.delete(path, user, name, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      branch_name = "#{GitflowType.name(type)}/#{name}"

      modules = BigkeeperParser.module_names

      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        GitService.new.verify_del(module_full_path, branch_name, module_name, type)
      end

      GitService.new.verify_del(path, branch_name, 'Home', type)
    ensure
    end
  end
end
