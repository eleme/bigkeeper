#!/usr/bin/ruby
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/info_plist_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/xcode_operator'
require 'big_keeper/model/operate_type'

module BigKeeper
  def self.prerelease(path, version, user, modules)
    DepService.dep_operator(path, user).release_start(path, version, user, modules)
  end

  def self.release(path, version, user, modules)
    BigkeeperParser.parse("#{path}/Bigkeeper")

    version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
    modules = BigkeeperParser.module_names

    if GitOperator.new.has_branch(path, "release/#{version}")
        DepService.dep_operator(path, user).release_finish(path, version, user, modules)
    else
        DepService.dep_operator(path, user).release_start(path, version, user, modules)
        DepService.dep_operator(path, user).release_finish(path, version, user, modules)
    end
  end

end
