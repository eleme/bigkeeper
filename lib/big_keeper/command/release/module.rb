#!/usr/bin/ruby
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/info_plist_operator'
require 'big_keeper/util/git_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'

module BigKeeper
  def self.release_module_start(path, version, user, module_name, ignore)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    module_path = BigkeeperParser.module_full_path(path, user, module_name)

    # stash
    StashService.new.stash(module_path, GitOperator.new.current_branch(module_path), module_name)

    #check
    if ignore != true
      GitOperator.new.check_merge(module_path, "feature/#{version}")
      GitOperator.new.check_diff(module_path, "develop", "master")
      Logger.highlight(%Q(#{module_name} release check finish))
    end

    # checkout to develop branch
    Logger.highlight(%Q(Start checkout #{module_name} to Branch develop))
    GitService.new.verify_checkout_pull(module_path, "develop")

    Logger.highlight(%Q(#{module_name} release start finish))
  end

## release finish
  def self.release_module_finish(path, version, user, module_name)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    module_path = BigkeeperParser.module_full_path(path, user, module_name)

    # check commit
    Logger.error("current branch has unpush files") if GitOperator.new.has_changes(module_path)
    # check out master
    Logger.highlight("'#{module_name}' checkout branch to master...")
    GitService.new.verify_checkout_pull(module_path, "master")

    Logger.highlight(%Q(Merge develop to master))
    # merge develop to master
    GitOperator.new.merge(module_path, "master")
    GitService.new.verify_push(module_path, "finish merge develop to master", "master", "#{module_name}")

    #修改 podspec 文件
    # TO DO: - advanced to use Regular Expression
    has_change = PodfileOperator.new.podspec_change(%Q(#{module_path}/#{module_name}.podspec), version, module_name)
    GitService.new.verify_push(module_path, "Change version number", "master", "#{module_name}") if has_change == true
    GitOperator.new.tag(module_path, version)

    # pod repo push
    PodOperator.pod_repo_push(module_path, module_name, BigkeeperParser.source_spec_path(module_name), version)
  end

end
