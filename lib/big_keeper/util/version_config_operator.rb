module BigKeeper
  class VersionConfigOperator
    def self.change_version(version_config_file, modules, version)
      temp_file = Tempfile.new('.version-config.gradle.tmp')
      begin
        File.open(version_config_file, 'r') do |file|
          file.each_line do |line|
            temp_file.puts(replace_module_version(line, modules, version))
          end
        end
        temp_file.close
        FileUtils.mv(temp_file.path, version_config_file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def self.replace_module_version(line, modules, version)
      modules.each do |module_name|
        version_alias = BigkeeperParser.module_version_alias(module_name)
        if !version_alias.nil? && !version_alias.empty? && line.match(/\s*#{version_alias}\s*=\s*('|")([\s\S]*)('|")\s*/)
          return line.sub(/(\s*#{version_alias}\s*=\s*)('|")([\s\S]*)('|")\s*/){"#{$1}\'#{version}\'"}
        end
      end
      line
    end
  end
end
