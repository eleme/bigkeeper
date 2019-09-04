#!/usr/bin/ruby
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/info_plist_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/xcode_operator'
require 'big_keeper/model/operate_type'

module BigKeeper
  def self.release_home_start(path, version, user, modules)
    DepService.dep_operator(path, user).release_home_start(path, version, user, modules)
  end

  def self.release_home_finish(path, version, user, modules)
    BigkeeperParser.parse("#{path}/Bigkeeper")

    version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
    modules = []
    BigkeeperParser.module_names.each do |module_name|
      module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
      if GitOperator.new.has_branch(module_full_path, "release/#{version}")
        Logger.highlight("#{module_name} has release/#{version}")
        modules << module_name
      end
    end

    DepService.dep_operator(path, user).release_home_finish(path, version, user, modules)
  end

end
