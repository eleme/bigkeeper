module BigKeeper
  # Operator for gitflow
  class GitflowOperator
    def start_feature(path, feature_name)
      init_git_flow(path)
      branch_name = GitOperator.new.current_branch(path)
      if branch_name != "feature/#{feature_name}"
        Dir.chdir(path) do
          p `git flow feature start #{feature_name}`
        end
      else
        p "Current feature name is the same with new feature, continue..."
      end
    end

    def init_git_flow(path)
      Dir.chdir(path) do
        clear_flag = 'Already initialized for gitflow'
        IO.popen("git flow init -d") do |io|
          io.each do |line|
            unless line.include? clear_flag
              `git push origin master`
              `git push origin develop`
            end
          end
        end
      end
    end

    def commit(path, message)
      Dir.chdir(path) do
        `git add .`
        `git commit -m "#{message}"`
      end
    end

    def publish_feature(path, feature_name)
      Dir.chdir(path) do
        p `git push origin feature/#{feature_name}`
      end
    end

    def pull_feature(path, feature_name)
      Dir.chdir(path) do
        p `git flow feature pull #{feature_name}`
      end
    end

    def finish_feature(path, feature_name)
      Dir.chdir(path) do
        p `git flow feature finish #{feature_name}`
      end
    end

    def start_hotfix(path, hotfix_name)
      Dir.chdir(path) do
        p `git flow hotfix start #{hotfix_name}`
      end
    end

    def finish_hotfix(path, hotfix_name)
      Dir.chdir(path) do
        p `git flow hotfix finish #{hotfix_name}`
      end
    end

    def start_release(path, release_name)
      Dir.chdir(path) do
        p `git flow release start #{release_name}`
      end
    end

    def finish_release(path, release_name)
      Dir.chdir(path) do
        p `git flow release finish #{release_name}`
      end
    end
  end
end
