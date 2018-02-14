require 'big_keeper/dependency/dep_operator'

require 'big_keeper/util/pod_operator'
require 'big_keeper/util/xcode_operator'
require 'big_keeper/util/cache_operator'

module BigKeeper
  # Operator for podfile
  class DepPodOperator < DepOperator
    def backup
      CacheOperator.new(@path).save('Podfile')
    end

    def recover
      cache_operator = CacheOperator.new(@path)
      cache_operator.load('Podfile')
      cache_operator.clean
    end

    def update_module_config(module_name, module_type, source)
      file = "#{@path}/Podfile"
      temp_file = Tempfile.new('.Podfile.tmp')

      begin
        File.open(file, 'r') do |file|
          file.each_line do |line|
            temp_file.puts generate_module_config(line, module_name, module_type, source)
          end
        end
        temp_file.close
        FileUtils.mv(temp_file.path, file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def install(should_update)
      PodOperator.pod_install(@path, should_update)
    end

    def open
      XcodeOperator.open_workspace(@path)
    end

    def generate_module_config(line, module_name, module_type, source)
      line.sub(/(\s*)pod(\s*)('|")#{module_name}('|")([\s\S]*)/){
        if ModuleType::PATH == module_type
          "#{$1}pod '#{module_name}', :path => '#{source}'"
        elsif ModuleType::GIT == module_type
          if GitType::BRANCH == source.type
            "#{$1}pod '#{module_name}', :git => '#{source.base}', :branch => '#{source.addition}'"
          elsif GitType::TAG == source.type
            "#{$1}pod '#{module_name}', :git => '#{source.base}', :tag => '#{source.addition}'"
          elsif GitType::COMMIT == source.type
            "#{$1}pod '#{module_name}', :git => '#{source.base}', :commit => '#{source.addition}'"
          else
            "#{$1}pod '#{module_name}', :git => '#{source.base}'"
          end
        elsif ModuleType::SPEC == module_type
          "#{$1}pod '#{module_name}', '#{source}'"
        else
          line
        end
      }
    end

    private :generate_module_config
  end
end
