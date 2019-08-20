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
        elsif ModuleOperateType::RELEASE_START == module_operate_type
          module_git = BigkeeperParser.module_git(module_name)
          branch_name = GitOperator.new.current_branch(@path)
          "#{$1}pod '#{module_name}#{$4}', :git => '#{module_git}', :branch => '#{branch_name}'"
        else
          line
        end
      }
    end

    def origin_config_of_module(module_name)
      origin_config = ''

      File.open("#{@path}/.bigkeeper/Podfile", 'r', :encoding => 'UTF-8') do |file|
        file.each_line do |line|
          if line =~ /(\s*)pod(\s*)('|")#{module_name}((\/[_a-zA-Z0-9]+)?)('|")([\s\S]*)/
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

      IO.popen("find /Users/#{username}/.cocoapods/repos/#{BigkeeperParser.source_spec_name(module_name)} -type d -name #{module_name}") do |io|
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

    def release_start(path, version, user, modules)
      BigkeeperParser.parse("#{path}/Bigkeeper")
      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      modules = release_check_changed_modules(path, user) if (modules.nil? || modules.empty?)

      if modules.nil? || modules.empty?
        Logger.default('no module need to release')
      end

      #stash home
      StashService.new.stash(path, GitOperator.new.current_branch(path), 'home')
      # delete cache
      CacheOperator.new(path).clean()
      # cache Podfile
      CacheOperator.new(path).save('Podfile')
      # checkout develop
      GitService.new.verify_checkout_pull(path, 'develop')
      # check
      GitOperator.new.check_diff(path, "develop", "master")

      #checkout release branch
      Logger.highlight(%Q(Start to checkout Home Branch release/#{version}))

      GitService.new.verify_checkout(path, "release/#{version}")

      raise Logger.error("Chechout release/#{version} failed.") unless GitOperator.new.current_branch(path) == "release/#{version}"

      Logger.highlight(%Q(Finish to release/#{version} for home project))

      modules.each do |module_name|
        Logger.highlight("release checkout release/#{version} for #{module_name}")
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)

        if GitOperator.new.has_branch(module_full_path, "release/#{version}")
          Logger.highlight("#{module_name} has release/#{version}")
          GitOperator.new.checkout(module_full_path, "release/#{version}")
        else
          Logger.highlight("#{module_name} dont have release/#{version}")
          ModuleService.new.release_start(path, user, modules, module_name, version)
          Logger.highlight("Push branch release/'#{version}' for #{module_name}...")
          GitOperator.new.push_to_remote(module_full_path, "release/#{version}")
        end

        DepService.dep_operator(path, user).update_module_config(
                                             module_name,
                                             ModuleOperateType::RELEASE_START)
      end

      # step 3 change Info.plist value
      InfoPlistOperator.new.change_version_build(path, version)

      GitService.new.verify_push(path, "Change version to #{version}", "release/#{version}", 'Home')
      # DepService.dep_operator(path, user).install(modules, OperateType::RELEASE, true)
      XcodeOperator.open_workspace(path)
    end

    def release_module_start(modules, module_name, version)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, module_name)
      GitService.new.verify_checkout(module_full_path, "release/#{version}")
    end

    def release_finish(path, version, user, modules)
      BigkeeperParser.parse("#{path}/Bigkeeper")
      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      modules = BigkeeperParser.module_names

      if GitOperator.new.has_branch(path, "release/#{version}")
        GitService.new.verify_checkout(path, "release/#{version}")

        PodfileOperator.new.replace_all_module_release(path, user, modules, ModuleOperateType::RELEASE)

        GitService.new.verify_push(path, "finish release branch", "release/#{version}", 'Home')

        # master
        GitOperator.new.checkout(path, "master")
        GitOperator.new.merge(path, "release/#{version}")
        GitService.new.verify_push(path, "release V#{version}", "master", 'Home')

        GitOperator.new.tag(path, version)

        # release branch
        GitOperator.new.checkout(path, "release/#{version}")
        CacheOperator.new(path).load('Podfile')
        CacheOperator.new(path).clean()
        GitOperator.new.commit(path, "reset #{version} Podfile")
        GitService.new.verify_push(path, "reset #{version} Podfile", "release/#{version}", 'Home')

        # develop
        GitOperator.new.checkout(path, "develop")
        GitOperator.new.merge(path, "release/#{version}")
        GitService.new.verify_push(path, "merge release/#{version} to develop", "develop", 'Home')
        GitOperator.new.check_diff(path, "develop", "master")

        Logger.highlight("Finish release home for #{version}")
      else
        raise Logger.error("There is no release/#{version} branch, please use release home start first.")
      end
    end

    private :generate_module_config, :origin_config_of_module, :find_lastest_tag
  end
end
