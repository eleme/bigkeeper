#!/usr/bin/ruby
require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/model/podfile_type'
require './big_keeper/util/info_plist_operator'

# 替换当前 podfile 中某个 module 为 pod #{module_name}, :git => '#{source.base}', :tag => '#{source.addition}'

module BigKeeper
  def self.start_module_release(path, version, user, module_name)
    main_path = File.expand_path("#{path}/Bigkeeper")
    BigkeeperParser.parse(main_path)
    module_release(path,
                version,
      BigkeeperParser::module_names,
      GitInfo.new(BigkeeperParser::home_git, GitType::TAG, version), user)
  end

  private
  def self.module_release(project_path, version, module_name, source)
    Dir.chdir(project_path) do
      PodfileOperator.new.find_and_replace(%Q(#{project_path}/Podfile),
                                                      module_name,
                                                      ModuleType::GIT,
                                                        source)
      p `pod install --project-directory=#{project_path}`
      p `open #{project_path}/*.xcworkspace`
    end
  end
end
