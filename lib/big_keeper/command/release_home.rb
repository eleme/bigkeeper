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
    p `git add .`
    p `git commit -m "release: V #{version}"`
    GitflowOperator.new.finish_release(path, version)
  end

  private
  def self.start_release(projectPath, version, modules, source, user)
    Dir.chdir(projectPath) do
      # step 0 Stash current branch
      StashService.new.stash(projectPath, GitOperator.new.current_branch(projectPath), user, modules)

      # step 1 checkout release
      if GitOperator.new.current_branch(projectPath) != "release/#{version}"
        if GitOperator.new.has_branch(projectPath, "release/#{version}")
          p `git checkout release/#{version}`
        else
          # GitflowOperator.new.start_release(projectPath, version)
          #     def start(path, name, type)
          GitflowOperator.new.start(projectPath, version, GitflowType::RELEASE)
          p `git push --set-upstream origin release/#{version}`
        end
      end

      # step 2 replace_modules
      PodfileOperator.new.replace_all_module_release(%Q(#{projectPath}/Podfile),
                                                      modules,

                                                      version,
                                                      source)

      # step 3 change Info.plist value
      InfoPlistOperator.new.change_version_build(projectPath, version)
    end
  end
end
