require 'big_keeper/dependency/dep_operator'


module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    PATH_VERSION_CONFIG = "doc/config/version-config.gradle"

    def backup
      cache_operator = CacheOperator.new(@path)
      cache_operator.save(PATH_VERSION_CONFIG)
    end

    def recover
      cache_operator = CacheOperator.new(@path)
      cache_operator.load(PATH_VERSION_CONFIG)
      cache_operator.clean
    end

    def update_module_config(module_name, module_operate_type)
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

    def generate_version_config_of_line(line, module_name, module_operate_type)
      if line.downcase.match(/([\s\S]*)#{module_name.downcase}version(\s*)=(\s*)('|")(\S*)('|")([\s\S]*)/)
        branch_name = GitOperator.new.current_branch(@path)
        version_name = ''
        # Get version part of source.addition

        if ModuleOperateType::ADD == module_operate_type
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

    def origin_config_of_module(module_name)
      origin_config = ''
      File.open("#{@path}/.bigkeeper/#{PATH_VERSION_CONFIG}", 'r') do |file|
        file.each_line do |line|
          if line.downcase.match(/([\s\S]*)#{module_name.downcase}version(\s*)=(\s*)('|")(\S*)('|")([\s\S]*)/)
            origin_config = line
            break
          end
        end
      end
      origin_config.chop
    end

    def install(should_update)
    end

    def open
    end
  end
end
