#!/usr/bin/ruby

require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'

require 'big_keeper/model/podfile_type'

require 'big_keeper/service/stash_service'
require 'big_keeper/service/module_service'


module BigKeeper
  def self.delete(path, user, name, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      branch_name = GitOperator.new.current_branch(path)

      Logger.error("Not a #{GitflowType.name(type)} branch, exit.") unless branch_name.include? GitflowType.name(type)

      full_name = branch_name.gsub(/#{GitflowType.name(type)}\//, '')

      modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                BigkeeperParser.module_names, ModuleType::PATH)
    ensure
    end
  end
end
