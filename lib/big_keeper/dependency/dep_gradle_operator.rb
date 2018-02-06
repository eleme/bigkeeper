require 'big_keeper/dependency/dep_operator'
require 'big_keeper/util/gradle_operator'

module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    def backup
      GradleOperator.new(@path).backup
    end

    def recover
      GradleOperator.new(@path).recover
    end

    def update_module_config(module_name, module_type, source)
      GradleOperator.new(@path).update_module_config(module_name, module_type, source)

      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)

      if ModuleType::PATH == module_type
        GradleOperator.new(module_full_path).backup

        all_path_modules = ModuleCacheOperator.new(@path).all_path_modules
        all_path_modules.each do |path_module_name|
          next if path_module_name == module_name
          module_full_path = BigkeeperParser.module_full_path(@path, @user, path_module_name)
          GradleOperator.new(module_full_path).update_module_config(module_name, module_type, source)
        end
      elsif ModuleType::GIT == module_type
        GradleOperator.new(module_full_path).recover

        all_path_modules = ModuleCacheOperator.new(@path).all_path_modules
        all_path_modules.each do |path_module_name|
          next if path_module_name == module_name
          module_full_path = BigkeeperParser.module_full_path(@path, @user, path_module_name)
          GradleOperator.new(module_full_path).update_module_config(module_name, module_type, source)
        end
      else
      end
    end

    def install(should_update)
      modules = ModuleCacheOperator.new(@path).all_path_modules
      GradleOperator.new(@path).update_setting_config('', @user, modules)

      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
        GradleOperator.new(module_full_path).update_setting_config(module_name, @user, modules)
      end
    end

    def open
    end
  end
end
