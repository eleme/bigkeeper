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

    def update_module_config(module_name, module_type, source)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)

      # get modules
      if ModuleType::PATH == module_type
        GradleOperator.new(module_full_path).backup

        add_modules = ModuleCacheOperator.new(@path).add_path_modules
        del_modules = ModuleCacheOperator.new(@path).del_path_modules
        GradleOperator.new(module_full_path).update_build_config(module_name, add_modules, ModuleType::PATH, source)
        GradleOperator.new(module_full_path).update_build_config(module_name, del_modules, ModuleType::RECOVER, source)

        modules = ModuleCacheOperator.new(@path).all_path_modules
        GradleOperator.new(module_full_path).update_settings_config(module_name, modules, @user)
      elsif ModuleType::GIT == module_type
        modules = []
        if 'develop' == source.addition || 'master' == source.addition
          modules = ModuleCacheOperator.new(@path).all_git_modules
        else
          modules = ModuleCacheOperator.new(@path).all_path_modules
        end
        GradleOperator.new(module_full_path).update_build_config(module_name, modules, module_type, source)
      elsif ModuleType::RECOVER == module_type
        GradleOperator.new(module_full_path).recover(true, true)
      end

      # update home config
      GradleOperator.new(@path).update_build_config('', modules, module_type, source)
      GradleOperator.new(@path).update_settings_config('', modules, @user)
    end

    def install(should_update)
    end

    def open
    end
  end
end
