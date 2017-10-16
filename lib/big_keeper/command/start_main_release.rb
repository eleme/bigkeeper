#!/usr/bin/ruby
require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/model/podfile_type'
require './big_keeper/util/info_plist_operator'

# 1.切换主工程的分支到 release分支
# 2.替换当前 podfile 中每个 module 为 pod #{module_name}, :git => '#{source.base}', :tag => '#{source.addition}'
# 3.替换 info.plist 中的 build version

module BigKeeper
  def self.start_main_release(path, version)
    main_path = File.expand_path(path)
    BigkeeperParser.parse(main_path)
    start_release(path, version, BigkeeperParser::module_names, git_info = GitInfo.new(BigkeeperParser::home_git, GitType::TAG, version))
  end

  def self.start_release(path, version, modules, source)
    projectPath = path.chomp("/Bigkeeper")
    Dir.chdir(projectPath) do
      # step 0
      # check git status

      # step 1 checkout release
      branches = `git branch`
      if branches.include? "release"
        p `git checkout release`
      else
        p `git branch release`
        p `git checkout release`
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
