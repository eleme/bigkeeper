#!/usr/bin/ruby
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/info_plist_operator'
require 'big_keeper/util/git_operator'
require 'big_keeper/util/logger'
require 'big_keeper/util/pod_operator'

module BigKeeper
  def self.release_module(path, version, user, modules, spec)
    BigkeeperParser.parse("#{path}/Bigkeeper")

    if !CommandLineUtil.double_check("modules #{modules} will publish version #{version}, are you sure?")
      Logger.error('module prerelease interrupt')
    end

    version = BigkeeperParser.version if version == 'Version in Bigkeeper file'

    for module_name in modules
      module_path = BigkeeperParser.module_full_path(path, user, module_name)

      StashService.new.stash(module_path, GitOperator.new.current_branch(module_path), module_name)
      GitService.new.verify_checkout_pull(module_path, "release/#{version}")
      GitService.new.verify_checkout_pull(module_path, "develop")

      has_diff = release_module_pre_check(module_path, module_name, version)

      if has_diff
        # merge release to develop
        branch_name = GitOperator.new.current_branch(module_path)
        if branch_name == "develop"
          GitOperator.new.merge_no_ff(module_path, "release/#{version}")
          GitOperator.new.push_to_remote(module_path, "develop")
        else
          Logger.error("current branch is not develop branch")
        end
      end

      # check commit
      Logger.error("current branch has unpush files") if GitOperator.new.has_changes(module_path)

      GitService.new.verify_checkout_pull(module_path, "release/#{version}")

      # check out master
      Logger.highlight("'#{module_name}' checkout branch to master...")
      GitService.new.verify_checkout_pull(module_path, "master")

      # merge release to master
      GitOperator.new.merge_no_ff(module_path, "release/#{version}")

      Logger.highlight(%Q(Merge "release/#{version}" to master))

      GitOperator.new.push_to_remote(module_path, "master")

      #修改 podspec 文件
      # TO DO: - advanced to use Regular Expression
      # has_change = PodfileOperator.new.podspec_change(%Q(#{module_path}/#{module_name}.podspec), version, module_name)
      # GitService.new.verify_push(module_path, "Change version number", "master", "#{module_name}") if has_change == true

      GitOperator.new.tag(module_path, version)
      # pod repo push
      if spec == true
        PodOperator.pod_repo_push(module_path, module_name, BigkeeperParser.source_spec_path(module_name), version)
      end
    end
  end

  def self.release_module_pre_check(module_path, module_name, version)
    #check
    #GitOperator.new.check_merge(module_path, "feature/#{version}")
    Logger.highlight(%Q(#{module_name} release pre-check finish))
    return GitOperator.new.check_diff(module_path, "develop", "release/#{version}")
  end

end
