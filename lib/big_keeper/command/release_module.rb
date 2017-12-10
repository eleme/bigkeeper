#!/usr/bin/ruby
require 'big_keeper/util/podfile_operator'
require 'big_keeper/util/gitflow_operator'
require 'big_keeper/model/podfile_type'
require 'big_keeper/util/info_plist_operator'
require 'big_keeper/util/git_operator'
require 'big_keeper/util/logger'

module BigKeeper
  def self.start_module_release(path, version, user, module_name)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    Dir.chdir(path) do
      module_release(BigkeeperParser::module_path(user, module_name),
                  version,
                  module_name,
        GitInfo.new(BigkeeperParser::home_git, GitType::TAG, version),
                    user)
    end
  end

  private
  def self.module_release(module_path, version, module_name, source, user)
    Dir.chdir(module_path) do
      if GitOperator.new.has_changes(module_path)
        StashService.new.stash_all(module_path, GitOperator.new.current_branch(module_path), user, module_name.split())
      end

      # step 1 checkout release
      Logger.highlight(%Q(Start checkout #{module_name} to Branch release/#{version}))
      if GitOperator.new.current_branch(module_path) != "release/#{version}"
        if GitOperator.new.has_branch(module_path, "release/#{version}")
          GitOperator.new.git_checkout(module_path, "release/#{version}")
        else
          GitflowOperator.new.start(module_path, version, GitflowType::RELEASE)
          GitOperator.new.first_push(module_path, "release/#{version}")
        end
      end

      #修改 podspec 文件
      # TO DO: - advanced to use Regular Expression
      PodfileOperator.new.podspec_change(%Q(#{module_path}/#{module_name}.podspec), version, module_name)
      GitOperator.new.commit(module_path, "update podspec")
      GitOperator.new.first_push(module_path, GitOperator.new.current_branch(module_path))

      # Pod lib lint in release/#{tag} branch
      Logger.highlight(%Q(Start Pod lib lint #{module_name}))
      has_error = false
      IO.popen("pod lib lint --allow-warnings --verbose --use-libraries --sources=#{BigkeeperParser::sourcemodule_path}") do |io|
        io.each do |line|
          has_error = true if line.include? "ERROR"
        end
      end
      if has_error
        Logger.error("Pod lib error in '#{module_name}'")
        return
      end

      # check out master
      if GitOperator.new.current_branch(module_path) != "master"
        current_name = GitOperator.new.current_branch(module_path)
        GitOperator.new.git_checkout(module_path, "master")
        Logger.highlight("Push branch '#{branch_name}' for '#{module_name}'...")
        GitService.new.verify_push(module_path, "finish #{GitflowType.name(GitflowType::RELEASE)} #{branch_name}", "master", "#{module_name}")
      end

      # to do rebase release to master
      Logger.highlight(%Q(Rebase develop to master))
      GitService.new.verify_rebase(module_path, 'develop', "#{module_name}")

      Logger.highlight(%Q(Start Pod repo push #{module_name}))
      IO.popen("pod repo push #{module_name} #{module_name}.podspec --allow-warnings --sources=#{BigkeeperParser::sourcemodule_path}") do |io|
        io.each do |line|
          has_error = true if line.include? "ERROR"
        end
      end
      if has_error
        Logger.error("Pod repo push in '#{module_name}'")
        return
      end

      GitOperator.new.tag(module_path, version)

      Logger.highlight(%Q(Success release #{module_name}))
    end
  end
end
