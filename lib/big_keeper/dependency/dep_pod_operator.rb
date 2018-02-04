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

    def modules_with_branch(modules, branch_name)
      file = "#{@path}/Podfile"
      matched_modules = []
      File.open(file, 'r') do |file|
        file.each_line do |line|
          modules.each do |module_name|
            if line =~ /pod\s*('|")#{module_name}('|")\s*,\s*:git\s*=>\s*\S*\s*,\s*:branch\s*=>\s*('|")#{branch_name}('|")\s*/
              matched_modules << module_name
            end
          end
        end
      end
      matched_modules
    end

    def modules_with_type(modules, module_type)
      file = "#{@path}/Podfile"
      matched_modules = []
      File.open(file, 'r') do |file|
        file.each_line do |line|
          modules.each do |module_name|
            if line =~ /pod\s*('|")#{module_name}('|")\s*,#{regex(module_type)}/
              matched_modules << module_name
            end
          end
        end
      end
      matched_modules
    end

    def regex(module_type)
      if ModuleType::PATH == module_type
        "\s*:path\s*=>\s*"
      elsif ModuleType::GIT == module_type
        "\s*:git\s*=>\s*"
      elsif ModuleType::SPEC == module_type
        "\s*('|\")"
      else
        ""
      end
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
      line.sub(/(\s*)pod(\s*)'(\S*)#{module_name}(\S*)'([\s\S]*)#([\s\S]*)/){
        if ModuleType::PATH == module_type
          "#{$1}pod '#{module_name}', :path => '#{source}' ##{$6}"
        elsif ModuleType::GIT == module_type
          # puts source.base
          # puts source.addition
          if GitType::BRANCH == source.type
            "#{$1}pod '#{module_name}', :git => '#{source.base}', :branch => '#{source.addition}' ##{$6}"
          elsif GitType::TAG == source.type
            "#{$1}pod '#{module_name}', :git => '#{source.base}', :tag => '#{source.addition}' ##{$6}"
          elsif GitType::COMMIT == source.type
            "#{$1}pod '#{module_name}', :git => '#{source.base}', :commit => '#{source.addition}' ##{$6}"
          else
            "#{$1}pod '#{module_name}', :git => '#{source.base}' ##{$6}"
          end
        elsif ModuleType::SPEC == module_type
          "#{$1}pod '#{module_name}', '#{source}' ##{$6}"
        else
          line
        end
      }
    end

    private :generate_module_config, :regex
  end
end
