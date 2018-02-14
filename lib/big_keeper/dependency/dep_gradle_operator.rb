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
      GradleOperator.new(@path).recover
    end

    def update_module_config(module_name, module_type, source)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
      modules = []
      if ModuleType::PATH == module_type
        modules = ModuleCacheOperator.new(@path).all_path_modules
      elsif ModuleType::GIT == module_type
        if 'develop' == source.addition || 'master' == source.addition
          modules = ModuleCacheOperator.new(@path).all_git_modules
        else
          modules = ModuleCacheOperator.new(@path).all_path_modules
        end
      else
      end

      GradleOperator.new(@path).update_settings_config('', modules, @user)
      GradleOperator.new(@path).update_build_config('', modules, module_type, source)

      if ModuleType::PATH == module_type
        GradleOperator.new(module_full_path).backup
        GradleOperator.new(module_full_path).update_settings_config(module_name, modules, @user)
      elsif ModuleType::GIT == module_type
        GradleOperator.new(module_full_path).recover
      else
      end

      GradleOperator.new(module_full_path).update_build_config(module_name, modules, module_type, source)
    end

    def install(should_update)
    end

    def open
    end
  end
end
