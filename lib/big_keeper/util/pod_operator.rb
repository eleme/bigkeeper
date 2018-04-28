require 'big_keeper/util/logger'
require 'open3'

module BigKeeper
  class PodOperator
    def self.pod_install(path, repo_update)
      # pod install
      if repo_update
        Logger.highlight('Start pod repo update, waiting...')
        cmd = 'pod repo update'
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          while line = stdout.gets
            puts line
          end
        end
      end
      Logger.highlight('Start pod install, waiting...')
      cmd = "pod install --project-directory=#{path}"
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        while line = stdout.gets
          puts line
        end
      end
      Logger.highlight('Finish pod install.')
    end
  end
end
