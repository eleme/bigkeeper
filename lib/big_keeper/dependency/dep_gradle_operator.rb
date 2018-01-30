require 'big_keeper/dependency/dep_operator'

module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    def backup
      cache_operator = CacheOperator.new(@path)
      cache_operator.save('setting.gradle')
      Dir.glob("#{@path}/*/build.gradle").each do |build_gradle_file_path|
        build_gradle_file = build_gradle_file_path.gsub!(/#{@path}/, '')
        cache_operator.save(build_gradle_file)
      end
    end

    def recover
      cache_operator = CacheOperator.new(@path)

      cache_operator.load('setting.gradle')
      Dir.glob("#{@path}/*/build.gradle").each do |build_gradle_file_path|
        build_gradle_file = build_gradle_file_path.gsub!(/#{@path}/, '')
        cache_operator.load(build_gradle_file)
      end

      cache_operator.clean
    end

    def modules_with_branch(modules, branch_name)
      snapshot_name = "#{branch_name}_SNAPSHOT"
      file = "#{@path}/app/build.gradle"

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
      file = "#{@path}/app/build.gradle"

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
      Dir.glob("#{@path}/*/build.gradle").each do |file|
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
    end

    def install(addition)
      modules = modules_with_type(BigkeeperParser.module_names, ModuleType::PATH)

      CacheOperator.new(@path).load('setting.gradle')

      begin
        File.open("#{@path}/setting.gradle", 'a') do |file|
          modules.each do |module_name|
            file.puts "include '#{prefix_of_module(module_name)}#{module_name.downcase}'\r\n"
            file.puts "project('#{prefix_of_module(module_name)}#{module_name.downcase}').projectDir = new File(rootProject.projectDir, '../#{module_name}/#{module_name.downcase}-lib')\r\n"
          end
        end
      ensure
      end
    end

    def prefix_of_module(module_name)
      file = "#{@path}/app/build.gradle"
      prefix = ''

      File.open(file, 'r') do |file|
        file.each_line do |line|
          if line =~ /(\s*)([\s\S]*)'(\S*)#{module_name.downcase}(\S*)'(\S*)/
            prefix = line.sub(/(\s*)([\s\S]*)'(\S*)#{module_name.downcase}(\S*)'(\S*)/){
              $3
            }
          end
        end
      end

      prefix.chop
    end

    def open
    end

    def generate_build_config(line, module_name, module_type, source)
      if ModuleType::PATH == module_type
        line.sub(/(\s*)compile(\s*)'(\S*)#{module_name.downcase}(\S*)'(\S*)/){
          "#{$1}compile project('#{$3}#{module_name.downcase}')"
        }
      elsif ModuleType::GIT == module_type
        branch_name = GitOperator.new.current_branch(@path)
        snapshot_name = "SNAPSHOT"

        # Get version part of source.addition
        if 'develop' == source.addition || 'master' == source.addition
          snapshot_name = branch_name.sub(/([\s\S]*)\/(\d+.\d+.\d+)_([\s\S]*)/){
            "#{$2}_SNAPSHOT"
          }
        else
          snapshot_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){
            "#{$2}_SNAPSHOT"
          }
        end
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
