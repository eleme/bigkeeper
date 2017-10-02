#!/usr/bin/ruby
require 'rexml/document'
include REXML

require '../util/podfile_operator'
require '../util/gitflow_operator'
require '../model/podfile_type'
require '../util/info_plist_operator'

# 1.切换主工程的分支到 release分支
# 2.替换当前 podfile 中每个 module 为 pod #{module_name}, :git => '#{source.base}', :tag => '#{source.addition}'
# 3.替换 info.plist 中的 build version

module BigKeeper
  def self.start_main_release(path, version)
    main_path = File.expand_path(path)
    BigkeeperParser.parse(main_path)

    p modules

    feature_name = "#{BigkeeperParser.version}_#{user}_#{name}"
    p feature_name
    start_new_feature(main_path, BigkeeperParser.version, modules)
  end

  def start_new_feature(path, version, modules)
    p %Q(cd #{main_path})
    # step 0
    # check git status

    # step 1 checkout release
    branches = `git branch -a`
    puts branches
    if branches.include?'release'
        p `git checkout release`
        else
        p `git branch release`
        start_new_feature(path, version, modules)
    end

    # step 2 replace_modules
    PodfileOperator.new.replace_all_module_release(%Q(#{path}/Podfile,
                                                    module_names,
                                                    version,
                                                    GitType::TAG))

    # step 3 change Info.plist value

  end
end
