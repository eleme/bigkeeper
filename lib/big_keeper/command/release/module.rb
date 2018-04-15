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

    module_path = self.get_module_path_default(path, user, module_name)

    # stash
    if GitOperator.new.has_changes(module_path)
      StashService.new.stash_all(module_path, GitOperator.new.current_branch(module_path), user, module_name.split())
    end

    #check
    if ignore != true
      unmerged_branchs = GitOperator.new.check_merge(module_path, "feature/#{version}")
      if (unmerged_branchs.size > 0)
        unmerged_branchs.map { |item|
            Logger.default(item)
        }
        Logger.error("Still has unmerged feature branch, please check")
        return
      end

      GitOperator.new.check_diff(module_path, "develop", "master")
      Logger.highlight(%Q(#{module_name} release check finish))
    end

    # checkout to develop branch
    if GitOperator.new.current_branch(module_path) != "develop"
      Logger.highlight(%Q(Start checkout #{module_name} to Branch develop))
      if GitOperator.new.has_branch(module_path, "develop")
        GitOperator.new.verify_checkout(module_path, "develop")
        GitOperator.new.pull(module_path, "develop")
      else
        Logger.error("Cann't find develop branch, please check.")
      end
    end

    Logger.highlight(%Q(#{module_name} release start finish))
  end

## release finish
  def self.release_module_finish(path, version, user, module_name)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    module_path = self.get_module_path_default(path, user, module_name)

    # check commit
    Logger.error("current branch has unpush files") if GitOperator.new.has_changes(module_path)
    # check out master
    if GitOperator.new.current_branch(module_path) != "master"
      current_name = GitOperator.new.current_branch(module_path)
      GitOperator.new.checkout(module_path, "master")
      GitOperator.new.pull(module_path)
      Logger.highlight("'#{current_name}' checkout branch to master...")
    end

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
    PodOperator.pod_repo_push(module_path, module_name, BigkeeperParser.sourcemodule_path, version)
  end

  def self.get_module_path_default(path, user, module_name)
    module_path = BigkeeperParser::module_path(user, module_name)
    if module_path == "../#{module_name}"
      path_array = path.split('/')
      path_array.pop()
      module_path = path_array.join('/') + "/#{module_name}"
    end
    module_path
  end
end
