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

    def release_home_start(modules, version)
      version_config_file = "#{@path}/doc/config/version-config.gradle"
      version = "#{version}-SNAPSHOT" unless version.include?'SNAPSHOT'
      VersionConfigOperator.change_version(version_config_file, modules, version)
    end

    def release_home_finish(modules, version)
      version_config_file = "#{@path}/doc/config/version-config.gradle"
      VersionConfigOperator.change_version(version_config_file, modules, version)
    end

    def open
    end

    def release_start(path, version, user, modules)
      BigkeeperParser.parse("#{path}/Bigkeeper")
      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
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
        ModuleService.new.release_start(path, user, modules, module_name, version)

        # Push home changes to remote
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        Logger.highlight("Push branch 'develop' for #{module_name}...")
        GitService.new.verify_push(
          module_full_path,
          "release start for #{version}",
          'develop',
          "#{module_name}")
      end

      #release home
      DepService.dep_operator(path, user).release_home_start(modules, version)

      # Push home changes to remote
      Logger.highlight("Push branch 'develop' for 'Home'...")
      GitService.new.verify_push(
        path,
        "release start for #{version}",
        'develop',
        'Home')
    end

    def self.release_finish(path, version, user, modules)
      BigkeeperParser.parse("#{path}/Bigkeeper")
      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      modules = release_check_changed_modules(path, user) if (modules.nil? || modules.empty?)

      if modules.nil? || modules.empty?
        Logger.error('no module need to release')
      end
      if !CommandLineUtil.double_check("module #{modules} will changed version to #{version}, are you sure?")
        Logger.error('release finish interrupt')
      end
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

      #release home
      DepService.dep_operator(path, user).release_home_finish(modules, version)

      # Push home changes to remote
      Logger.highlight("Push branch 'develop' for 'Home'...")
      GitService.new.verify_push(
        path,
        "release finish for #{version}",
        'develop',
        'Home')
    end

  end
end
