require 'big_keeper/util/logger'
require 'big_keeper/util/gradle_content_generator'

module BigKeeper
  class GradleFileOperator
    @path
    @user
    def initialize(path, user)
      @path = path
      @user = user
    end

    def get_module_depends(build_file, module_name)
      Logger.highlight("get module #{module_name} depends ...")
      depend_modules = []
      modules = ModuleCacheOperator.new(@path).all_path_modules
      File.open(build_file, 'r') do |file|
        file.each_line do |line|
          modules.each do |name|
            if line.strip().index('//') != 0 && !line.include?(BigkeeperParser.module_maven(module_name)) && !depend_modules.include?(name) && line.include?(BigkeeperParser.module_maven(name))
              depend_modules << name
            end
          end
        end
      end
      print "module #{module_name} depends: "
      p depend_modules
      depend_modules
    end

    def update_module_settings(module_name, settings_file, depend_modules)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
      cache_path = File.expand_path("#{module_full_path}/.bigkeeper")
      big_settings_file = "#{cache_path}/#{module_name}/bigkeeper_settings.gradle"

      if depend_modules.empty? && !File.exist?(big_settings_file)
        return
      end

      result = ''
      depend_modules.each do |name|
        artifact_id = BigkeeperParser.module_maven_artifact(name)
        path = BigkeeperParser.module_full_path(@path, @user, name)
        source = BigkeeperParser.module_source(name)
        result << "include \':module:#{artifact_id}\'\nproject(':module:#{artifact_id}').projectDir = new File('#{path}/#{source}')\n"
      end

      dest_path = File.dirname(big_settings_file)
      FileUtils.mkdir_p(dest_path) unless File.exist?(dest_path)
      file = File.new("#{cache_path}/#{module_name}/bigkeeper_settings.gradle", 'w')
      begin
        file << result
        file.close
      ensure
        file.close
      end

      if has_bigkeeper_config(settings_file)
        return
      end

      temp_file = Tempfile.new('.settings.gradle.tmp')
      begin
        File.open(settings_file, 'r') do |file|
          file.each_line do |line|
            temp_file.puts(line)
          end
        end
        temp_file.puts(GradleConentGenerator.generate_bigkeeper_settings_gradle_content(big_settings_file))
        temp_file.close
        FileUtils.mv(temp_file.path, settings_file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def update_module_build(build_file, module_name, depend_modules, version_name)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
      cache_path = File.expand_path("#{module_full_path}/.bigkeeper")
      big_build_file = "#{cache_path}/#{module_name}/bigkeeper_build.gradle"

      if depend_modules.empty? && !File.exist?(big_build_file)
        return
      end

      result = "configurations.all {\n\tresolutionStrategy {\n"
      depend_modules.each do |name|
        module_maven = BigkeeperParser.module_maven(name)
        result << "\t\tforce \'#{module_maven}:#{version_name}-SNAPSHOT\'\n"
      end
      result << "\t}\n}\n"

      dest_path = File.dirname(big_build_file)
      FileUtils.mkdir_p(dest_path) unless File.exist?(dest_path)
      file = File.new("#{cache_path}/#{module_name}/bigkeeper_build.gradle", 'w')
      begin
        file << result
        file.close
      ensure
        file.close
      end

      if has_bigkeeper_config(build_file)
        return
      end

      temp_file = Tempfile.new('.build.gradle.tmp')
      begin
        File.open(build_file, 'r') do |file|
          file.each_line do |line|
            temp_file.puts(line)
          end
        end
        temp_file.puts(GradleConentGenerator.generate_bigkeeper_build_gradle_content(big_build_file))
        temp_file.close
        FileUtils.mv(temp_file.path, build_file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def get_home_depends()
      path_modules = ModuleCacheOperator.new(@path).all_path_modules
      git_modules = ModuleCacheOperator.new(@path).all_git_modules
      path_modules | git_modules
    end

    def update_home_settings(settings_file, depend_modules)
      cache_path = File.expand_path("#{@path}/.bigkeeper")
      big_settings_file = "#{cache_path}/bigkeeper_settings.gradle"

      if depend_modules.empty? && !File.exist?(big_settings_file)
        return
      end

      result = ''
      depend_modules.each do |name|
        artifact_id = BigkeeperParser.module_maven(name).split(':')[1]
        path = BigkeeperParser.module_full_path(@path, @user, name)
        source = BigkeeperParser.module_source(name)
        result << "include \':module:#{artifact_id}\'\nproject(':module:#{artifact_id}').projectDir = new File('#{path}/#{source}')\n"
      end

      dest_path = File.dirname(big_settings_file)
      FileUtils.mkdir_p(dest_path) unless File.exist?(dest_path)
      file = File.new("#{cache_path}/bigkeeper_settings.gradle", 'w')
      begin
        file << result
        file.close
      ensure
        file.close
      end

      if has_bigkeeper_config(settings_file)
        return
      end

      temp_file = Tempfile.new('.settings.gradle.tmp')
      begin
        File.open(settings_file, 'r') do |file|
          file.each_line do |line|
            temp_file.puts(line)
          end
        end
        temp_file.puts(GradleConentGenerator.generate_bigkeeper_settings_gradle_content(big_settings_file))
        temp_file.close
        FileUtils.mv(temp_file.path, settings_file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def update_home_build(build_file, depend_modules, version_name)
      cache_path = File.expand_path("#{@path}/.bigkeeper")
      big_build_file = "#{cache_path}/bigkeeper_build.gradle"

      if depend_modules.empty? && !File.exist?(big_build_file)
        return
      end

      result = "configurations.all {\n\tresolutionStrategy {\n"
      depend_modules.each do |module_name|
        module_maven = BigkeeperParser.module_maven(module_name)
        result << "\t\tforce \'#{module_maven}:#{version_name}-SNAPSHOT\'\n"
      end
      result << "\t}\n}\n"

      dest_path = File.dirname(big_build_file)
      FileUtils.mkdir_p(dest_path) unless File.exist?(dest_path)
      file = File.new("#{cache_path}/bigkeeper_build.gradle", 'w')
      begin
        file << result
        file.close
      ensure
        file.close
      end

      if has_bigkeeper_config(build_file)
        return
      end

      temp_file = Tempfile.new('.build.gradle.tmp')
      begin
        File.open(build_file, 'r') do |file|
          file.each_line do |line|
            temp_file.puts(line)
          end
        end
        temp_file.puts(GradleConentGenerator.generate_bigkeeper_build_gradle_content(big_build_file))
        temp_file.close
        FileUtils.mv(temp_file.path, build_file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def update_module_version_name(build_file, version_name)
      temp_file = Tempfile.new('.build.gradle.tmp')
      isDefaultConfig = false
      isBigkeeperScript = false
      isBigkeeperBackupScript = false
      hasBigkeeperBackup = false
      begin
        File.open(build_file, 'r') do |file|
          file.each_line do |line|
            if line.include?('defaultConfig')
              isDefaultConfig = true
            elsif line.include?('bigkeeper config start')
              isBigkeeperScript = true
            elsif line.include?('bigkeeper config end')
              isBigkeeperScript = false
            elsif line.include?('bigkeeper config backup start')
              isBigkeeperBackupScript = true
              hasBigkeeperBackup = true
            elsif line.include?('bigkeeper config backup end')
              isBigkeeperBackupScript = false
            end

            if isDefaultConfig && !isBigkeeperBackupScript && line.include?('versionName')
              if !hasBigkeeperBackup
                temp_file.puts("\t\t//bigkeeper config backup start")
                temp_file.puts("\t\t//"+line.strip)
                temp_file.puts("\t\t//bigkeeper config backup end")
              end

              if isBigkeeperScript
                temp_file.puts("\t\tversionName \'#{version_name}\'")
              else
                temp_file.puts("\t\t//bigkeeper config start")
                temp_file.puts("\t\tversionName \'#{version_name}\'")
                temp_file.puts("\t\t//bigkeeper config end")
              end
              isDefaultConfig = false
            else
              temp_file.puts(line)
            end
          end
        end
        temp_file.close
        FileUtils.mv(temp_file.path, build_file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def update_module_depends(build_file, settings_file, module_name, version_name)
      depend_modules = get_module_depends(build_file, module_name)
      update_module_settings(module_name, settings_file, depend_modules)
      update_module_build(build_file, module_name, depend_modules, version_name)
    end

    def update_home_depends(build_file, settings_file, type)
      depend_modules = get_home_depends()
      update_home_settings(settings_file, depend_modules)
      update_home_build(build_file, depend_modules, generate_version_name(type))
    end

    def generate_version_name(type)
      branch_name = GitOperator.new.current_branch(@path)
      version_name = ''
      if OperateType::FINISH == type
        version_name = branch_name.sub(/([\s\S]*)\/(\d+.\d+.\d+)_([\s\S]*)/){ $2 }
      else
        version_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){ $2 }
      end
      version_name
    end

    def recover_bigkeeper_config_file(bigkeeper_config_file)
      if !File.exist?(bigkeeper_config_file)
        return
      end
      temp_file = Tempfile.new('.bigkeeper_config.tmp')
      isBigkeeperScript = false
      isBigkeeperBackupScript = false
      begin
        File.open(bigkeeper_config_file, 'r') do |file|
          file.each_line do |line|
            if line.include?('bigkeeper config start')
              isBigkeeperScript = true
            elsif line.include?('bigkeeper config end')
              isBigkeeperScript = false
            elsif line.include?('bigkeeper config backup start')
              isBigkeeperBackupScript = true
            elsif line.include?('bigkeeper config backup end')
              isBigkeeperBackupScript = false
            elsif isBigkeeperBackupScript
              temp_file.puts(line.gsub('//',''))
            elsif !isBigkeeperScript
              temp_file.puts(line)
            end
          end
        end
        temp_file.close
        FileUtils.mv(temp_file.path, bigkeeper_config_file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def has_bigkeeper_config(file)
      File.open(file, 'r') do |file|
        file.each_line do |line|
          if line.include?('bigkeeper config start')
            return true
          end
        end
      end
      false
    end

  end
end
