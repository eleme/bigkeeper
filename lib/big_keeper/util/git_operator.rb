require 'big_keeper/util/logger'

module BigKeeper
  # Operator for got
  class GitOperator
    def current_branch(path)
      Dir.chdir(path) do
        `git rev-parse --abbrev-ref HEAD`.chop
      end
    end

    def has_remote_branch(path, branch_name)
      has_branch = false
      IO.popen("cd #{path}; git branch -r") do |io|
        io.each do |line|
          has_branch = true if line.include? branch_name
        end
      end
      has_branch
    end

    def has_local_branch(path, branch_name)
      has_branch = false
      IO.popen("cd #{path}; git branch") do |io|
        io.each do |line|
          has_branch = true if line.include? branch_name
        end
      end
      has_branch
    end

    def has_branch(path, branch_name)
      has_branch = false
      IO.popen("cd #{path}; git branch -a") do |io|
        io.each do |line|
          has_branch = true if line.include? branch_name
        end
      end
      has_branch
    end

    def checkout(path, branch_name)
      Dir.chdir(path) do
        IO.popen("git checkout #{branch_name}") do |io|
          io.each do |line|
            Logger.error("Checkout #{branch_name} failed.") if line.include? 'error'
          end
        end
      end
    end

    def fetch(path)
      Dir.chdir(path) do
        `git fetch origin`
      end
    end

    def rebase(path, branch_name)
      Dir.chdir(path) do
        `git rebase origin/#{branch_name}`
      end
    end

    def clone(path, git_base)
      Dir.chdir(path) do
        `git clone #{git_base}`
      end
    end

    def commit(path, message)
      Dir.chdir(path) do
        `git add .`
        `git commit -m "#{Logger.formatter_output(message)}"`
      end
    end

    def push_to_remote(path, branch_name)
      Dir.chdir(path) do
        `git push -u origin #{branch_name}`
      end
      GitOperator.new.check_push_success(path, branch_name, "origin/#{branch_name}")
    end

    def pull(path)
      Dir.chdir(path) do
        `git pull`
      end
    end

    def has_commits(path, branch_name)
      has_commits = false
      IO.popen("cd #{path}; git log --branches --not --remotes") do |io|
        io.each do |line|
          has_commits = true if line.include? "(#{branch_name})"
        end
      end
      has_commits
    end

    def has_changes(path)
      has_changes = true
      clear_flag = 'nothing to commit, working tree clean'
      IO.popen("cd #{path}; git status") do |io|
        io.each do |line|
          has_changes = false if line.include? clear_flag
        end
      end
      has_changes
    end

    def discard(path)
      Dir.chdir(path) do
        `git checkout . && git clean -xdf`
      end
    end

    def del_local(path, branch_name)
      Dir.chdir(path) do
        `git branch -D #{branch_name}`
      end
    end

    def del_remote(path, branch_name)
      Dir.chdir(path) do
        `git push origin --delete #{branch_name}`
      end
    end

    def user
      `git config user.name`.chop
    end

    def tag(path, version)
      tags = Array.new
      IO.popen("cd #{path}; git tag") do |io|
        io.each do |line|
          tags << line
        end
      end
      unless tags.include? "#{version}\n"
        Dir.chdir(path) do
          `git tag -a #{version} -m "release: V #{version}" master;`
          `git push --tags`
        end
        return
      end
      Logger.highlight("tag already exists in the remote, skip this step")
    end

    def tag_list(path)
      tag_list = Array.new
      IO.popen("cd #{path}; git tag -l") do |io|
        io.each do |line|
          unless line=~(/[a-zA-Z]/)
            tag_list << line
          end
        end
      end
      tag_list
    end

    def check_merge(path, condition)
      unmerged_branch = Array.new
      IO.popen("cd #{path}; git branch --no-merged") do |io|
        io.each do |line|
          unmerged_branch.push(line) if line.include? "#{condition}"
        end
      end
      if (unmerged_branch.size > 0)
        unmerged_branch.map { |item|
            Logger.default(item)
        }
        Logger.error("Still has unmerged feature branch, please check")
      end
    end

    def check_diff(path, branch, compare_branch)
      compare_branch_commits = Array.new
      IO.popen("cd #{path}; git log --left-right #{branch}...#{compare_branch} --pretty=oneline") do |io|
        io.each do |line|
          compare_branch_commits.push(line) if (line.include? '>') && (line.include? "Merge branch #{branch} into #{compare_branch}")
        end
      end
      if compare_branch_commits.size > 0
        compare_branch_commits.map { |item|
            Logger.default(item)
        }
        Logger.error("#{compare_branch} branch has commit doesn't committed in #{branch}, please check")
      else
        Logger.highlight("#{compare_branch} branch doesn't have commit before #{branch}")
      end
    end

    def merge(path, branch_name)
      IO.popen("cd #{path}; git merge #{branch_name}") do |line|
        Logger.error("Merge conflict in #{branch_name}") if line.include? 'Merge conflict'
      end
    end

    def check_push_success(path, branch, compare_branch)
      compare_branch_commits = Array.new
      IO.popen("cd #{path}; git log --left-right #{branch}...#{compare_branch} --pretty=oneline") do |io|
        io.each do |line|
          compare_branch_commits.push(line) if (line.include? '>') || (line.include? 'fatal')
        end
      end
      if compare_branch_commits.size > 0
        compare_branch_commits.map { |item|
            Logger.default(item)
        }
        Logger.error("#{branch} branch push unsuccess, please check")
      else
        Logger.highlight("#{branch} branch push success")
      end
    end

  end

  # p GitOperator.new.user
  # BigStash::StashOperator.new("/Users/mmoaay/Documents/eleme/BigKeeperMain").list
end
