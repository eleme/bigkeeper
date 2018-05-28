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

    version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
    modules = BigkeeperParser.module_names

    #stash
    StashService.new.stash_all(path, GitOperator.new.current_branch(path), user, modules)

    # delete cache
    CacheOperator.new(path).clean()
    # cache Podfile
    CacheOperator.new(path).save('Podfile')

    # check
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
    XcodeOperator.open_workspace(path)
  end

  def self.release_home_finish(path, version)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
    Logger.highlight("Start finish release home for #{version}")

    if GitOperator.new.has_branch(path, "release/#{version}")
      if GitOperator.new.current_branch(path) != "release/#{version}"
        GitOperator.new.checkout(path, "release/#{version}")
      end

      GitOperator.new.commit(path, "release: V #{version}")
      GitOperator.new.push_to_remote(path, "release/#{version}")

      # master
      GitOperator.new.checkout(path, "master")
      GitOperator.new.merge(path, "release/#{version}")
      GitOperator.new.push_to_remote(path, "master")

      GitOperator.new.tag(path, version)

      # release branch
      GitOperator.new.checkout(path, "release/#{version}")
      CacheOperator.new(path).load('Podfile')
      CacheOperator.new(path).clean()
      GitOperator.new.commit(path, "reset #{version} Podfile")
      GitOperator.new.push_to_remote(path, "release/#{version}")

      # develop
      GitOperator.new.checkout(path, "develop")
      GitOperator.new.merge(path, "release/#{version}")
      GitOperator.new.push_to_remote(path, "develop")
      GitOperator.new.check_diff(path, "develop", "master")

      Logger.highlight("Finish release home for #{version}")
    else
      raise Logger.error("There is no release/#{version} branch, please use release home start first.")
    end
  end

end
