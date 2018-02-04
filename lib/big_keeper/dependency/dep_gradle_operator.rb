require 'big_keeper/dependency/dep_operator'
require 'big_keeper/util/gradle_operator'

module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    def backup
      GradleOperator.new.backup(@path)
    end

    def recover
      GradleOperator.new.recover(@path)
    end

    def modules_with_branch(modules, branch_name)
      full_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){ $2 }
      file = "#{@path}/app/build.gradle"

      matched_modules = []
      File.open(file, 'r') do |file|
        file.each_line do |line|
          modules.each do |module_name|
            if line =~ /compile\s*('|")\S*#{module_name.downcase}:#{full_name}('|")\S*/
              matched_modules << module_name
            end
          end
        end
      end
      matched_modules
    end

    def modules_with_type(modules, module_type)
      file = "#{@path}/app/build.gradle"

      matched_modules = []
      File.open(file, 'r') do |file|
        file.each_line do |line|
          modules.each do |module_name|
            if line =~ regex(module_type, module_name)
              matched_modules << module_name
            end
          end
        end
      end
      matched_modules
    end

    def regex(module_type, module_name)
      if ModuleType::PATH == module_type
        /compile\s*project\(('|")\S*#{module_name.downcase}('|")\)\S*/
      elsif ModuleType::GIT == module_type
        /compile\s*('|")\S*#{module_name.downcase}\S*('|")\S*/
      elsif ModuleType::SPEC == module_type
        /compile\s*('|")\S*#{module_name.downcase}\S*('|")\S*/
      else
        //
      end
    end

    def update_module_config(module_name, module_type, source)
      gradle_operator = GradleOperator.new
      gradle_operator.update_module_config(@path, module_name, module_type, source)

      modules = modules_with_type(BigkeeperParser.module_names, ModuleType::PATH)
      modules.each do |sub_module_name|
        module_full_path = BigkeeperParser.module_full_path(@path, @user, sub_module_name)
        gradle_operator.update_module_config(module_full_path, module_name, module_type, source)
      end

      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
      if ModuleType::PATH == module_type
        GradleOperator.new.backup(module_full_path)
      else
        GradleOperator.new.recover(module_full_path)
      end
    end

    def install(should_update)
      modules = modules_with_type(BigkeeperParser.module_names, ModuleType::PATH)

      GradleOperator.new.update_setting_config(@path, @user, modules)

      modules = modules_with_type(BigkeeperParser.module_names, ModuleType::PATH)
      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
        GradleOperator.new.update_setting_config(module_full_path, @user, modules)
      end
    end

    def open
    end

    private :regex
  end
end
