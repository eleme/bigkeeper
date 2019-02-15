require 'big_keeper/util/cache_operator'

module BigKeeper
  # Operator for podfile
  class GradleOperator

    PATH_VERSION_CONFIG = "doc/config/version-config.gradle"

    def initialize(path)
      @path = path
    end

    def backup
      cache_operator = CacheOperator.new(@path)
      cache_operator.save(PATH_VERSION_CONFIG)
    end

    def recover(settings_config, build_config)
      cache_operator = CacheOperator.new(@path)
      cache_operator.load(PATH_VERSION_CONFIG)
      cache_operator.clean
    end

    def update_version_config(module_name, module_operate_type)
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

        if ModuleOperateType::DELETE == module_operate_type
          return origin_config_of_module(module_name)
        elsif ModuleOperateType::PUBLISH == module_operate_type
          version_name = branch_name.sub(/([\s\S]*)\/(\d+.\d+.\d+)_([\s\S]*)/){ $2 }
        else
          version_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){ $2 }
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

    private :generate_version_config_of_line, :origin_config_of_module
  end
end
