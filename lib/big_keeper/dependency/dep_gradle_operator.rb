require 'big_keeper/dependency/dep_operator'
require 'big_keeper/util/gradle_module_operator'
require 'big_keeper/util/gradle_file_operator'
require 'big_keeper/model/operate_type'
require 'big_keeper/util/version_config_operator'

module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    BUILD_GRADLE = "app/build.gradle"
    SETTINGS_GRADLE = "settings.gradle"

    def backup
    end

    def recover
      build_file = "#{@path}/#{BUILD_GRADLE}"
      settings_file = "#{@path}/#{SETTINGS_GRADLE}"
      GradleFileOperator.new(@path, @user).recover_bigkeeper_config_file(build_file)
      GradleFileOperator.new(@path, @user).recover_bigkeeper_config_file(settings_file)

      cache_operator = CacheOperator.new(@path)
      cache_operator.clean
    end

    def update_module_config(module_name, module_operate_type)
      if ModuleOperateType::ADD == module_operate_type
        GradleModuleOperator.new(@path, @user, module_name).update_module(ModuleOperateType::ADD)
      elsif ModuleOperateType::DELETE == module_operate_type
        GradleModuleOperator.new(@path, @user, module_name).recover()
      elsif ModuleOperateType::FINISH == module_operate_type
        GradleModuleOperator.new(@path, @user, module_name).update_module(ModuleOperateType::FINISH)
      elsif ModuleOperateType::PUBLISH == module_operate_type
        GradleModuleOperator.new(@path, @user, module_name).recover()
      end
    end

    def install(modules, type, should_update)
      if OperateType::START == type || OperateType::UPDATE == type || OperateType::SWITCH == type || OperateType::FINISH == type
        GradleFileOperator.new(@path, @user).update_home_depends("#{@path}/#{BUILD_GRADLE}", "#{@path}/#{SETTINGS_GRADLE}",type)
      elsif OperateType::PUBLISH == type
        recover()
      end
    end

    def release_module_start(modules, module_name, version)
        module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
        version_config_file = "#{module_full_path}/doc/config/version-config.gradle"
        version = "#{version}-SNAPSHOT" unless version.include?'SNAPSHOT'
        VersionConfigOperator.change_version(version_config_file, modules, version)
    end

    def release_module_finish(modules, module_name, version)
        module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
        version_config_file = "#{module_full_path}/doc/config/version-config.gradle"
        VersionConfigOperator.change_version(version_config_file, modules, version)
    end

    def open
    end

    def release_check_changed_modules(path, user)
      changed_modules = []
      BigkeeperParser.parse("#{path}/Bigkeeper")
      allModules = BigkeeperParser.module_names
      allModules.each do |module_name|
        if ModuleService.new.release_check_changed(path, user, module_name)
          changed_modules << module_name
        end
      end
      changed_modules
    end

## release cmd
    def release_home_start(path, version, user, modules)
      BigkeeperParser.parse("#{path}/Bigkeeper")
      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      modules = BigkeeperParser.module_names

      if modules.nil? || modules.empty?
        Logger.default('no module need to release')
      end

      #stash home
      StashService.new.stash(path, GitOperator.new.current_branch(path), 'home')
      # delete cache
      CacheOperator.new(path).clean()
      # check
      GitOperator.new.check_diff(path, "develop", "master")

      #checkout release branch
      Logger.highlight(%Q(Start to checkout Home Branch release/#{version}))

      GitService.new.verify_checkout(path, "release/#{version}")

      raise Logger.error("Chechout release/#{version} failed.") unless GitOperator.new.current_branch(path) == "release/#{version}"

      Logger.highlight(%Q(Finish to release/#{version} for home project))

      if !modules.nil? && !modules.empty?
        modules.each do |module_name|
          Logger.highlight("release checkout release/#{version} for #{module_name}")
          module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

          if GitOperator.new.has_branch(module_full_path, "release/#{version}")
            Logger.highlight("#{module_name} has release/#{version}")
            GitService.new.verify_checkout_pull(module_full_path, "release/#{version}")
          else
            Logger.highlight("#{module_name} dont have release/#{version}")
            GitService.new.verify_checkout(module_full_path, "release/#{version}")
            Logger.highlight("Push branch release/'#{version}' for #{module_name}...")
            GitOperator.new.push_to_remote(module_full_path, "release/#{version}")
          end
        end
      end

      Logger.highlight("Home project release home start finished")
    end

    def release_home_finish(path, version, user, modules)
      BigkeeperParser.parse("#{path}/Bigkeeper")
      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'

      if modules.nil? || modules.empty?
        Logger.default('no module need to release')
      end

      #stash home
      StashService.new.stash(path, GitOperator.new.current_branch(path), 'home')
      # delete cache
      CacheOperator.new(path).clean()
      # check
      GitOperator.new.check_diff(path, "develop", "master")

      for module_name in modules
        module_path = BigkeeperParser.module_full_path(path, user, module_name)

        StashService.new.stash(module_path, GitOperator.new.current_branch(module_path), module_name)
        GitService.new.verify_checkout_pull(module_path, "release/#{version}")
        GitService.new.verify_checkout_pull(module_path, "develop")

        has_diff = GitOperator.new.check_diff(module_path, "develop", "release/#{version}")
        if has_diff
          branch_name = GitOperator.new.current_branch(module_path)
          if branch_name == "develop"
            GitOperator.new.merge_no_ff(module_path, "release/#{version}")
            GitOperator.new.push_to_remote(module_path, "develop")
          else
            Logger.error("current branch is not develop branch")
          end
        end

        # check out master
        Logger.highlight("'#{module_name}' checkout branch to master...")
        GitService.new.verify_checkout_pull(module_path, "master")

        # merge release to master
        GitOperator.new.merge_no_ff(module_path, "release/#{version}")
        Logger.highlight(%Q(Merge "release/#{version}" to master))
        GitOperator.new.push_to_remote(module_path, "master")
      end

      if GitOperator.new.has_branch(path, "release/#{version}")

        GitService.new.verify_checkout_pull(path, "release/#{version}")

        PodfileOperator.new.replace_all_module_release(path, user, modules, ModuleOperateType::RELEASE)

        GitService.new.verify_push(path, "finish release branch", "release/#{version}", 'Home')

        # master
        GitService.new.verify_checkout(path, "master")
        GitOperator.new.merge(path, "release/#{version}")
        GitService.new.verify_push(path, "release V#{version}", "master", 'Home')

        GitOperator.new.tag(path, version)

        # release branch
        GitOperator.new.checkout(path, "release/#{version}")
        CacheOperator.new(path).load('Podfile')
        CacheOperator.new(path).clean()
        GitOperator.new.commit(path, "reset #{version} Podfile")
        GitService.new.verify_push(path, "reset #{version} Podfile", "release/#{version}", 'Home')

        # develop
        GitOperator.new.checkout(path, "develop")
        GitOperator.new.merge(path, "release/#{version}")
        GitService.new.verify_push(path, "merge release/#{version} to develop", "develop", 'Home')
        GitOperator.new.check_diff(path, "develop", "master")

        Logger.highlight("Finish release home for #{version}")
      else
        raise Logger.error("There is no release/#{version} branch, please use release home start first.")
      end

    end

## prerelease cmd
    def prerelease_start(path, version, user, modules)
      BigkeeperParser.parse("#{path}/Bigkeeper")

      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      modules = BigkeeperParser.module_names if (modules.nil? || modules.empty?)
      modules = release_check_changed_modules(path, user) if (modules.nil? || modules.empty?)
      if modules.nil? || modules.empty?
        Logger.error('no module need to release')
      end

      if !CommandLineUtil.double_check("module #{modules} will changed version to #{version}-SNAPSHOT, are you sure?")
        Logger.error('release start interrupt')
      end

      #stash home
      StashService.new.stash(path, GitOperator.new.current_branch(path), 'home')
      # delete cache
      CacheOperator.new(path).clean()
      # checkout develop
      GitService.new.verify_checkout_pull(path, 'develop')

      modules.each do |module_name|
        Logger.highlight("release start module #{module_name}")
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        ModuleService.new.release_start(path, user, modules, module_name, version)
        GitService.new.verify_push(module_full_path, "Change version to #{version}-SNAPSHOT", "develop", module_name)
      end

      #release home
      DepService.dep_operator(path, user).prerelease_home_start(path, version, user, modules)

      # Push home changes to remote
      Logger.highlight("Push branch 'develop' for 'Home'...")
      GitService.new.verify_push(
        path,
        "release start for #{version}",
        'develop',
        'Home')
    end

    def prerelease_finish(path, version, user, modules)
      BigkeeperParser.parse("#{path}/Bigkeeper")
      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'

      #stash home
      StashService.new.stash(path, GitOperator.new.current_branch(path), 'home')
      # delete cache
      CacheOperator.new(path).clean()
      # checkout develop
      GitService.new.verify_checkout_pull(path, 'develop')

      modules.each do |module_name|
       Logger.highlight("release start module #{module_name}")
       ModuleService.new.release_finish(path, user, modules, module_name, version)
      end

      # release home
      DepService.dep_operator(path, user).prerelease_home_finish(path, version, user, modules)

      # Push home changes to remote
      Logger.highlight("Push branch 'develop' for 'Home'...")
      GitService.new.verify_push(
       path,
       "release finish for #{version}",
       'develop',
       'Home')
    end

    def prerelease_home_start(path, version, user, modules)
      version_config_file = "#{path}/doc/config/version-config.gradle"
      version = "#{version}-SNAPSHOT" unless version.include?'SNAPSHOT'
      VersionConfigOperator.change_version(version_config_file, modules, version)
    end

    def prerelease_home_finish(path, version, user, modules)
      version_config_file = "#{@path}/doc/config/version-config.gradle"
      VersionConfigOperator.change_version(version_config_file, modules, version)
    end

  end
end
