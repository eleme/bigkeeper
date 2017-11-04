#!/usr/bin/ruby
require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/model/podfile_type'
require './big_keeper/util/info_plist_operator'

# 1.切换主工程的分支到 release分支
# 2.替换当前 podfile 中每个 module 为 pod #{module_name}, :git => '#{source.base}', :tag => '#{source.addition}'
# 3.替换 info.plist 中的 build version

module BigKeeper
  def self.release_home_start(path, version, user)
    puts user
    main_path = File.expand_path(path + "/BigKeeper")
    BigkeeperParser.parse(main_path)
    start_release(path, version, BigkeeperParser::module_names, GitInfo.new(BigkeeperParser::home_git, GitType::TAG, version), user)
  end

  def self.release_home_finish(path, version)
    Dir.chdir(path) do
      if GitOperator.new.has_branch(project_path, "release/#{version}")
        if GitOperator.new.current_branch(project_path) != "release/#{version}"
          GitOperator.new.commit(path, "release: V #{version}")
          GitOperator.new.push(path, "release/#{version}")
          GitflowOperator.new.finish_release(path, version)
          if GitOperator.new.current_branch(project_path) == "master"
            GitOperator.new.tag(path, version)
          else
            GitOperator.new.git_checkout(project_path, "master")
            GitOperator.new.tag(path, version)
          end
        else
          raise "Not in release branch, please check your branches."
        end
      else
        raise "Not has release branch, use release start first."
      end
    end
  end

  private
  def self.start_release(project_path, version, modules, source, user)
    Dir.chdir(project_path) do
      # step 0 Stash current branch
      StashService.new.stash(project_path, GitOperator.new.current_branch(project_path), user, modules)

      # step 1 checkout release
      if GitOperator.new.current_branch(project_path) != "release/#{version}"
        if GitOperator.new.has_branch(project_path, "release/#{version}")
          GitOperator.new.git_checkout(project_path, "release/#{version}")
        else
          GitflowOperator.new.start(project_path, version, GitflowType::RELEASE)
          GitOperator.new.push(project_path, "release/#{version}")
        end
      end

      # step 2 replace_modules
      PodfileOperator.new.replace_all_module_release(%Q(#{project_path}/Podfile),
                                                      modules,
                                                      version,
                                                      source)

      # step 3 change Info.plist value
      InfoPlistOperator.new.change_version_build(project_path, version)

      p `pod install --project-directory=#{project_path}`
      p `open #{project_path}/*.xcworkspace`
    end
  end
end
