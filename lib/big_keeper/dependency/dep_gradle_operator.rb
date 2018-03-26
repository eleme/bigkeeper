require 'big_keeper/dependency/dep_operator'
require 'big_keeper/util/gradle_operator'

module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    def backup
      GradleOperator.new(@path).backup
      modules = ModuleCacheOperator.new(@path).all_path_modules
      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
        GradleOperator.new(module_full_path).backup
      end
    end

    def recover
      GradleOperator.new(@path).recover(true, false)
    end

    def update_module_config(module_name, module_operate_type)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)

      # get modules
      if ModuleOperateType::ADD == module_operate_type
        GradleOperator.new(module_full_path).backup

        add_modules = ModuleCacheOperator.new(@path).add_path_modules
        del_modules = ModuleCacheOperator.new(@path).del_path_modules
        GradleOperator.new(module_full_path).update_build_config(module_name, add_modules, ModuleOperateType::ADD)
        GradleOperator.new(module_full_path).update_settings_config(module_name, add_modules, ModuleOperateType::ADD, @user)
        GradleOperator.new(module_full_path).update_build_config(module_name, del_modules, ModuleOperateType::DELETE)
        GradleOperator.new(module_full_path).update_settings_config(module_name, del_modules, ModuleOperateType::DELETE, @user)
      elsif ModuleOperateType::DELETE == module_operate_type
        GradleOperator.new(module_full_path).recover(true, true)
      elsif ModuleOperateType::FINISH == module_operate_type
        modules = ModuleCacheOperator.new(@path).all_path_modules
        GradleOperator.new(module_full_path).update_build_config(module_name, modules, ModuleOperateType::FINISH)
      elsif ModuleOperateType::PUBLISH == module_operate_type
        modules = ModuleCacheOperator.new(@path).all_git_modules
        GradleOperator.new(module_full_path).update_build_config(module_name, modules, ModuleOperateType::PUBLISH)
      end

      GradleOperator.new(@path).update_build_config('', [module_name], module_operate_type)
      GradleOperator.new(@path).update_settings_config('', [module_name], module_operate_type, @user)
    end

    def install(should_update)
    end

    def open
    end
  end
end
