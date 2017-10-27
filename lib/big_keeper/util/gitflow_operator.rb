require './big_keeper/model/gitflow_type'

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
            unless line.include? clear_flag
              `git push origin master`
              `git push origin develop`
            end
          end
        end
      end
    end

    def finish_release(path, release_name)
      Dir.chdir(path) do
        puts release_name
        p `git flow release finish #{release_name}`
      end
    end
  end
end
