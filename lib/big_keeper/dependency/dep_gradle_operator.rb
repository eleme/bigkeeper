require 'big_keeper/dependency/dep_operator'

module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    def backup
      CacheOperator.new(@path).save('lib/setting.gradle')
      CacheOperator.new(@path).save('build.gradle')
    end

    def recover
      cache_operator = CacheOperator.new(@path)
      cache_operator.load('lib/setting.gradle')
      cache_operator.load('build.gradle')
      cache_operator.clean
    end

    def modules_with_branch(modules, branch_name)
      snapshot_name = "#{branch_name}_SNAPSHOT"

      file = "#{@path}/build.gradle"
      matched_modules = []
      File.open(file, 'r') do |file|
        file.each_line do |line|
          modules.each do |module_name|
            if line =~ /compile\s*'\S*#{module_name.downcase}:#{snapshot_name}'\S*/
              matched_modules << module_name
              break
            end
          end
        end
      end
      matched_modules
    end

    def modules_with_type(modules, type)
      file = "#{@path}/build.gradle"
      matched_modules = []
      File.open(file, 'r') do |file|
        file.each_line do |line|
          modules.each do |module_name|
            if line =~ regex(type, module_name)
              matched_modules << module_name
              break
            end
          end
        end
      end
      matched_modules
    end

    def regex(type, module_name)
      if ModuleType::PATH == type
        /compile\s*project\('\S*#{module_name.downcase}'\)\S*/
      elsif ModuleType::GIT == type
        /compile\s*'\S*#{module_name.downcase}\S*'\S*/
      elsif ModuleType::SPEC == type
        //
      else
        //
      end
    end

    def find_and_replace(module_name, module_type, source)
      file = "#{@path}/build.gradle"
      temp_file = Tempfile.new('.build.gradle.tmp')

      begin
        File.open(file, 'r') do |file|
          file.each_line do |line|
            temp_file.puts generate_build_config(line, module_name, module_type, source)
          end
        end
        temp_file.close
        FileUtils.mv(temp_file.path, file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def install(addition)
    end

    def open
    end

    def generate_build_config(line, module_name, module_type, source)
      if ModuleType::PATH == module_type
        line.sub(/(\s*)compile(\s*)'(\S*)#{module_name.downcase}(\S*)'(\S*)/){
          "#{$1}compile project('#{$3}#{module_name.downcase}')"
        }
      elsif ModuleType::GIT == module_type
        if 'develop' == source.addition
        end
        snapshot_name = "#{source.addition}_SNAPSHOT"
        line.sub(/(\s*)([\s\S]*)'(\S*)#{module_name.downcase}(\S*)'(\S*)/){
          "#{$1}compile '#{$3}#{module_name.downcase}:#{snapshot_name}'"
        }
      else
        line
      end
    end

    def generate_setting_config(module_name, module_type, source)
    end

    private :generate_build_config, :generate_setting_config, :regex
  end
end
