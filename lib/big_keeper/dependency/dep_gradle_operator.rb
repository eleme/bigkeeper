require 'big_keeper/dependency/dep_operator'
require 'big_keeper/util/gradle_module_operator'
require 'big_keeper/util/gradle_file_operator'
require 'big_keeper/model/operate_type'

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

    def open
    end
  end
end
