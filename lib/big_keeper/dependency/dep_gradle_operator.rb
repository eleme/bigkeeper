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
  end
end
