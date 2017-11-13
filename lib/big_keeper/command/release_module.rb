#!/usr/bin/ruby
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/model/podfile_type'
require 'big_keeper/util/info_plist_operator'
require 'big_keeper/util/git_operator'
require 'big_keeper/util/log_util'

module BigKeeper
  def self.start_module_release(path, version, user, module_name)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    Dir.chdir(path) do
      module_release(BigkeeperParser::module_path(user, BigkeeperParser::module_names),
                  version,
                  module_name,
        GitInfo.new(BigkeeperParser::home_git, GitType::TAG, version),
                    user)
    end
  end

  private
  def self.module_release(path, version, module_name, source, user)
    Dir.chdir(path) do
      if GitOperator.new.has_changes(path)
        StashService.new.stash(path, GitOperator.new.current_branch(path), user, module_name.split())
      end

      #修改 podspec 文件
      PodfileOperator.new.podspec_change(%Q(#{path}/#{module_name}.podspec), version, module_name)

      p `pod lib lint --allow-warnings --verbose --use-libraries --sources=#{BigkeeperParser::source}`

      GitOperator.new.commit(path, "update podspec")
      GitOperator.new.push(path, GitOperator.new.current_branch(path))
      if GitOperator.new.current_branch(path) != "master"
        current_name = GitOperator.new.current_branch(path)
        p `git checkout master`
        p `git merge release/#{current_name}`
        p `git push`
      end
      GitOperator.new.tag(path, version)
      
      p `pod repo push #{module_name} #{module_name}.podspec --allow-warnings --sources=#{BigkeeperParser::source}`
    end
  end
end
