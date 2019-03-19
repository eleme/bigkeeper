require 'big_keeper/dependency/dep_operator'
require 'big_keeper/util/gradle_operator'
require 'big_keeper/model/operate_type'

module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    PATH_VERSION_CONFIG = "doc/config/version-config.gradle"
    LOCAL_MODULE_BUILD = "module/module.gradle"
    GLOBAL_MODULE_BUILD =  "module/global.gradle"

    def backup
      GradleOperator.new(@path).backup
    end

    def recover
      GradleOperator.new(@path).recover
    end

    def update_project_config(modules, type)
      raise "You should override this method in subclass."
    end

    def update_module_config(module_name, module_operate_type)
      update_local_depend(module_name, module_operate_type)
      update_project_version_config(module_name, module_operate_type)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
      GradleOperator.new(module_full_path).update_version_config(module_name, module_operate_type)
    end

    def update_project_version_config(module_name, module_operate_type)
      temp_file = Tempfile.new('.version-config.gradle.tmp')
      begin
        File.open("#{@path}/#{PATH_VERSION_CONFIG}", 'r') do |file|
          file.each_line do |line|
            new_line = generate_version_config_of_line(
              line,
              module_name,
              module_operate_type)
            temp_file.puts(new_line)
          end
        end
        temp_file.close
        FileUtils.mv(temp_file.path, "#{@path}/#{PATH_VERSION_CONFIG}")
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def update_local_depend(module_name, module_operate_type)
      if !File.exist?("#{@path}/#{LOCAL_MODULE_BUILD}")
        FileUtils.cp("#{@path}/#{GLOBAL_MODULE_BUILD}", "#{@path}/#{LOCAL_MODULE_BUILD}")
      end
      temp_file = Tempfile.new('.module.gradle.tmp')
      begin
        File.open("#{@path}/#{LOCAL_MODULE_BUILD}", 'r') do |file|
          file.each_line do |line|
            new_line = generate_local_depend_of_line(
              line,
              module_name,
              module_operate_type)
            temp_file.puts(new_line)
          end
        end
        temp_file.close
        FileUtils.mv(temp_file.path, "#{@path}/#{LOCAL_MODULE_BUILD}")
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def generate_version_config_of_line(line, module_name, module_operate_type)
      if line.downcase.match(/([\s\S]*)#{module_name.downcase.gsub('-','')}version(\s*)=(\s*)('|")(\S*)('|")([\s\S]*)/)
        branch_name = GitOperator.new.current_branch(@path)
        version_name = ''
        # Get version part of source.addition

        if ModuleOperateType::ADD == module_operate_type
          version_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){ $2 }+'-SNAPSHOT'
        elsif ModuleOperateType::FINISH == module_operate_type
          version_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){ $2 }
        elsif ModuleOperateType::DELETE == module_operate_type
          return origin_config_of_module(module_name)
        else
          version_name = branch_name.sub(/([\s\S]*)\/(\d+.\d+.\d+)_([\s\S]*)/){ $2 }
        end
      return line.sub(/([\s\S]*)Version(\s*)=(\s*)('|")(\S*)('|")([\s\S]*)/){
          "#{$1}Version = '#{version_name}'"}
      end
      line
    end

    def generate_local_depend_of_line(line, module_name, module_operate_type)
      if line.downcase.match(/([\s\S]*):module:#{module_name.downcase.gsub('-','')}([\s\S]*)/)
        if ModuleOperateType::ADD == module_operate_type
          line = line.gsub('//','')
        else
          line = line.gsub('//','')
          line = '//' + line
        end
      end
      line
    end

    def origin_config_of_module(module_name)
      origin_config = ''
      File.open("#{@path}/.bigkeeper/#{PATH_VERSION_CONFIG}", 'r') do |file|
        file.each_line do |line|
          if line.downcase.match(/([\s\S]*)#{module_name.downcase.gsub('-','')}version(\s*)=(\s*)('|")(\S*)('|")([\s\S]*)/)
            origin_config = line
            break
          end
        end
      end
      origin_config.chop
    end

    def install(modules, type, should_update)
      if OperateType::SWITCH == type
        all_modules = BigkeeperParser.module_names

        #close all
        all_modules.each do |module_name|
          update_local_depend(module_name, ModuleOperateType::DELETE)
        end

        #open modules
        modules.each do |module_name|
          update_local_depend(module_name, ModuleOperateType::ADD)
        end
      end
    end

    def open
    end
  end
end
