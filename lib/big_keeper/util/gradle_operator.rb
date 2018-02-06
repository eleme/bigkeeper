require 'big_keeper/util/cache_operator'

module BigKeeper
  # Operator for podfile
  class GradleOperator
    def initialize(path)
      @path = File.expand_path(path)
    end

    def backup
      cache_operator = CacheOperator.new(@path)
      cache_operator.save('settings.gradle')
      Dir.glob("#{@path}/*/build.gradle").each do |build_gradle_file_path|
        build_gradle_file = build_gradle_file_path.gsub!(/#{@path}/, '')
        cache_operator.save(build_gradle_file)
      end
    end

    def recover
      cache_operator = CacheOperator.new(@path)
      cache_operator.load('settings.gradle')
      cache_operator.clean
    end

    def update_setting_config(user, modules)
      CacheOperator.new(@path).load('settings.gradle')
      begin
        File.open("#{@path}/settings.gradle", 'a') do |file|
          modules.each do |module_name|
            file.puts "include ':#{module_name.downcase}'\r\n"
            file.puts "project(':#{module_name.downcase}')." \
              "projectDir = new File(rootProject.projectDir," \
              "'#{BigkeeperParser.module_path(user, module_name)}/#{module_name.downcase}-lib')\r\n"
          end
        end
      ensure
      end
    end

    def update_module_config(module_name, module_type, source)
      Dir.glob("#{@path}/*/build.gradle").each do |file|
        temp_file = Tempfile.new('.build.gradle.tmp')
        begin
          version_flag = false
          version_index = 0

          File.open(file, 'r') do |file|
            file.each_line do |line|
              version_flag = true if line.include? 'modifyPom'
              if version_flag
                version_index += 1 if line.include? '{'
                version_index -= 1 if line.include? '}'

                version_flag = false if 0 == version_flag

                temp_file.puts generate_version_config(line, module_name, module_type, source)
              else
                temp_file.puts generate_compile_config(line, module_name, module_type, source)
              end
            end
          end
          temp_file.close
          FileUtils.mv(temp_file.path, file)
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    end

    def generate_version_config(line, module_name, module_type, source)
      if ModuleType::GIT == module_type
        branch_name = GitOperator.new.current_branch(@path)
        full_name = ''

        # Get version part of source.addition
        if 'develop' == source.addition || 'master' == source.addition
          full_name = branch_name.sub(/([\s\S]*)\/(\d+.\d+.\d+)_([\s\S]*)/){ $2 }
        else
          full_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){ $2 }
        end
        line.sub(/(\s*)version ('|")(\S*)('|")([\s\S]*)/){
          "#{$1}version '#{full_name}'#{$5}"
        }
      elsif ModuleType::SPEC == module_type
        line.sub(/(\s*)version ('|")(\S*)('|")([\s\S]*)/){
          "#{$1}version '#{source}'#{$5}"
        }
      else
        line
      end
    end

    def prefix_of_module(module_name)
      prefix = ''
      Dir.glob("#{@path}/.bigkeeper/*/build.gradle").each do |file|
        File.open(file, 'r') do |file|
          file.each_line do |line|
            if line =~ /(\s*)([\s\S]*)('|")(\S*)#{module_name.downcase}(\S*)('|")(\S*)/
              prefix = line.sub(/(\s*)([\s\S]*)('|")(\S*)#{module_name.downcase}(\S*)('|")(\S*)/){
                $4
              }
              break
            end
          end
        end
        break unless prefix.empty?
      end

      prefix.chop
    end

    def generate_compile_config(line, module_name, module_type, source)
      if ModuleType::PATH == module_type
        line.sub(/(\s*)([\s\S]*)('|")(\S*)#{module_name.downcase}(\S*)('|")(\S*)/){
          "#{$1}compile project(':#{module_name.downcase}')"
        }
      elsif ModuleType::GIT == module_type
        branch_name = GitOperator.new.current_branch(@path)
        full_name = ''

        # Get version part of source.addition
        if 'develop' == source.addition || 'master' == source.addition
          full_name = branch_name.sub(/([\s\S]*)\/(\d+.\d+.\d+)_([\s\S]*)/){ $2 }
        else
          full_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){ $2 }
        end
        line.sub(/(\s*)([\s\S]*)('|")(\S*)#{module_name.downcase}(\S*)('|")(\S*)/){
          "#{$1}compile '#{prefix_of_module(module_name)}#{module_name.downcase}:#{full_name}-SNAPSHOT'"
        }
      elsif ModuleType::SPEC == module_type
        line.sub(/(\s*)([\s\S]*)('|")(\S*)#{module_name.downcase}(\S*)('|")(\S*)/){
          "#{$1}compile '#{prefix_of_module(module_name)}#{module_name.downcase}:#{source}'"
        }
      else
        line
      end
    end

    private :generate_compile_config, :generate_version_config, :prefix_of_module
  end
end
