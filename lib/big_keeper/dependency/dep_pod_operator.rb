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

    def update_module_config(module_name, module_operate_type)
      file = "#{@path}/Podfile"
      temp_file = Tempfile.new('.Podfile.tmp')

      begin
        File.open(file, 'r') do |file|
          file.each_line do |line|
            temp_file.puts generate_module_config(line, module_name, module_operate_type)
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

    def generate_module_config(line, module_name, module_operate_type)
      line.sub(/(\s*)pod(\s*)('|")#{module_name}('|")([\s\S]*)/){
        if ModuleOperateType::ADD == module_operate_type
          module_path = BigkeeperParser.module_path(@user, module_name)
          "#{$1}pod '#{module_name}', :path => '#{module_path}'"
        elsif ModuleOperateType::DELETE == module_operate_type
          origin_config_of_module = origin_config_of_module(module_name)
          if origin_config_of_module.empty?
            line
          else
            origin_config_of_module
          end
        elsif ModuleOperateType::FINISH == module_operate_type
          module_git = BigkeeperParser.module_git(module_name)
          branch_name = GitOperator.new.current_branch(@path)
          "#{$1}pod '#{module_name}', :git => '#{module_git}', :branch => '#{branch_name}'"
        elsif ModuleOperateType::PUBLISH == module_operate_type
          module_git = BigkeeperParser.module_git(module_name)
          branch_name = GitOperator.new.current_branch(@path)
          base_branch_name = GitflowType.base_branch(GitService.new.current_branch_type(@path))
          "#{$1}pod '#{module_name}', :git => '#{module_git}', :branch => '#{base_branch_name}'"
        else
          line
        end
      }
    end

    def origin_config_of_module(module_name)
      origin_config = ''

      File.open("#{@path}/.bigkeeper/Podfile", 'r') do |file|
        file.each_line do |line|
          if line =~ /(\s*)pod(\s*)('|")#{module_name}('|")([\s\S]*)/
            origin_config = line
            break
          end
        end
      end

      origin_config.chop
    end

    private :generate_module_config, :origin_config_of_module
  end
end
