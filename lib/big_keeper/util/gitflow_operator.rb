require 'big_keeper/model/gitflow_type'

module BigKeeper
  # Operator for gitflow
  class GitflowOperator
    def start(path, name, type)
      init_git_flow(path)
      Dir.chdir(path) do
        gitflow_type_name = GitflowType.name(type)
        p `git flow #{gitflow_type_name} start #{name}`
      end
    end

    def init_git_flow(path)
      Dir.chdir(path) do
        clear_flag = 'Already initialized for gitflow'
        IO.popen('git flow init -d') do |io|
          io.each do |line|
            if !line.include? clear_flag
              GitOperator.new.push(module_full_path, 'master') if !GitOperator.new.has_remote_branch(module_full_path, 'master')
              GitOperator.new.push(module_full_path, 'develop') if !GitOperator.new.has_remote_branch(module_full_path, 'develop')
              break
            end
          end
        end
      end
    end

    def finish_release(path, release_name)
      Dir.chdir(path) do
        p `git checkout master`
        p `git merge release/#{release_name}`
        p `git push`
        p `git checkout develop`
        p `git merge release/#{release_name}`
        p `git push`
        p `git branch -d release/#{release_name}`
      end
    end
  end
end
