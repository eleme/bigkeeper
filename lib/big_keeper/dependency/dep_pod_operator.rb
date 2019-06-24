require 'big_keeper/dependency/dep_operator'

require 'big_keeper/util/pod_operator'
require 'big_keeper/util/xcode_operator'
require 'big_keeper/util/cache_operator'
require 'big_keeper/util/file_operator'

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
      temp_file = Tempfile.new('.Podfile.tmp', :encoding => 'UTF-8')

      begin
        File.open(file, 'r', :encoding => 'UTF-8') do |file|
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

    def install(modules, type, should_update)
      PodOperator.pod_install(@path, should_update)
    end

    def open
      XcodeOperator.open_workspace(@path)
    end

    def generate_module_config(line, module_name, module_operate_type)
      line.sub(/(\s*)pod(\s*)('|")#{module_name}((\/[_a-zA-Z0-9]+)?)('|")([\s\S]*)/){
        if ModuleOperateType::ADD == module_operate_type
          module_path = BigkeeperParser.module_path(@user, module_name)
          "#{$1}pod '#{module_name}#{$4}', :path => '#{module_path}'"
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
          "#{$1}pod '#{module_name}#{$4}', :git => '#{module_git}', :branch => '#{branch_name}'"
        elsif ModuleOperateType::PUBLISH == module_operate_type
          module_git = BigkeeperParser.module_git(module_name)
          branch_name = GitOperator.new.current_branch(@path)
          base_branch_name = GitflowType.base_branch(GitService.new.current_branch_type(@path))
          "#{$1}pod '#{module_name}#{$4}', :git => '#{module_git}', :branch => '#{base_branch_name}'"
        elsif ModuleOperateType::RELEASE == module_operate_type
          module_git = BigkeeperParser.module_git(module_name)
          lastest_tag, is_spec = find_lastest_tag(module_name)
          if is_spec == true
            Logger.default("#{module_name} lastest tag is #{lastest_tag}, this tag has published.")
            "#{$1}pod '#{module_name}#{$4}', '#{lastest_tag}'"
          else
            Logger.default("#{module_name} lastest tag is #{lastest_tag}, this tag not publish.")
            "#{$1}pod '#{module_name}#{$4}', :git => '#{module_git}', :tag => '#{lastest_tag}'"
          end
        else
          line
        end
      }
    end

    def origin_config_of_module(module_name)
      origin_config = ''

      File.open("#{@path}/.bigkeeper/Podfile", 'r', :encoding => 'UTF-8') do |file|
        file.each_line do |line|
          if line =~ /(\s*)pod(\s*)('|")#{module_name}('|")([\s\S]*)/
            origin_config = line
            break
          end
        end
      end

      origin_config.chop
    end

    def find_lastest_tag(module_name)
      username = FileOperator.new.current_username
      tags_repos_pwd = Array.new
      tags_spec_list = Array.new
      tags_module_list = Array.new

      IO.popen("find /Users/#{username}/.cocoapods/repos -type d -name #{module_name}") do |io|
        io.each do |line|
          tags_repos_pwd.push(line) if line.include? "#{module_name}"
        end
      end
      for pwd in tags_repos_pwd do
        path = pwd.chomp
        IO.popen("cd '#{path}'; ls") do |io|
          io.each do |line|
            tags_spec_list.push(line)
          end
        end
      end

      tags_module_list = GitOperator.new.tag_list(BigkeeperParser.module_full_path(@path, @user, module_name))
      last_tag = tags_module_list[tags_module_list.length - 1]
      if tags_module_list.include?(last_tag) && tags_spec_list.include?(last_tag)
        return [last_tag.chomp, true]
      else
        return [last_tag.chomp, false]
      end
    end

    private :generate_module_config, :origin_config_of_module, :find_lastest_tag
  end
end
