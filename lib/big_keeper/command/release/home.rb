#!/usr/bin/ruby
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/info_plist_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/xcode_operator'

module BigKeeper
  def self.release_home_start(path, version, user)
    BigkeeperParser.parse("#{path}/Bigkeeper")

    modules = BigkeeperParser.module_names

    #stash
    StashService.new.stash_all(path, GitOperator.new.current_branch(path), user, modules)

    # check
    GitOperator.new.check_merge(module_path, "feature/#{version}")
    GitOperator.new.check_diff(path, "develop", "master")

    #checkout release branch
    Logger.highlight(%Q(Start to checkout Branch release/#{version}))
    if GitOperator.new.current_branch(path) != "release/#{version}"
      if GitOperator.new.has_branch(path, "release/#{version}")
        GitOperator.new.checkout(path, "release/#{version}")
      else
        GitflowOperator.new.start(path, version, GitflowType::RELEASE)
        GitOperator.new.push_to_remote(path, "release/#{version}")
      end
    end

    Logger.highlight(%Q(Start to release/#{version}))
    # step 2 replace_modules
    PodfileOperator.new.replace_all_module_release(path,
                                                   user,
                                                   modules,
                                                   ModuleOperateType::RELEASE)

    # step 3 change Info.plist value
    InfoPlistOperator.new.change_version_build(path, version)

    DepService.dep_operator(path, user).install(true)
    XcodeOperator.new.open_workspace(path)
  end

  def self.release_home_finish(path, version)
    if GitOperator.new.has_branch(path, "release/#{version}")
      if GitOperator.new.current_branch(path) == "release/#{version}"
        GitOperator.new.commit(path, "release: V #{version}")
        GitOperator.new.push_to_remote(path, "release/#{version}")
        GitflowOperator.new.finish_release(path, version)
        if GitOperator.new.current_branch(path) == "master"
          GitOperator.new.tag(path, version)
        else
          GitOperator.new.checkout(path, "master")
          GitOperator.new.tag(path, version)
        end
      else
        raise Logger.error("Not in release branch, please check your branches.")
      end
    else
      raise Logger.error("Not has release branch, please use release start first.")
    end
  end

end
