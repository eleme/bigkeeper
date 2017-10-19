#!/usr/bin/ruby
require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/model/podfile_type'
require './big_keeper/util/info_plist_operator'


# 替换当前 podfile 中某个 module 为 pod #{module_name}, :git => '#{source.base}', :tag => '#{source.addition}'

module BigKeeper
  def self.start_module_release(path, module_name)
    main_path = File.expand_path(path)
    BigkeeperParser.parse(main_path)

    module_release(path,
            module_name,
            GitInfo.new(BigkeeperParser::home_git, GitType::BRANCH, "develop"))
  end

  private
  def self.module_release(path, module_name, source)
    projectPath = path.chomp("/Bigkeeper")
    Dir.chdir(projectPath) do
      PodfileOperator.new.find_and_replace(%Q(#{projectPath}/Podfile),
                                                      module_name,
                                                      ModuleType::GIT,
                                                        source)
      p `pod install --project-directory=#{projectPath}`
      p `open #{projectPath}/*.xcworkspace`
    end
  end
end
