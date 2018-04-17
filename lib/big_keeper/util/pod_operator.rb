require 'big_keeper/util/logger'
require 'open3'

module BigKeeper
  class PodOperator
    def self.pod_install(path, repo_update)
      # pod install
      if repo_update
        PodOperator.pod_update_private_repos()
      end
      Logger.highlight('Start pod install, waiting...')
      cmd = "pod install --project-directory=#{path}"
      Open3.popen3(cmd) do |stdin , stdout , stderr, wait_thr|
        while line = stdout.gets
          puts line
        end
      end
      Logger.highlight('Finish pod install.')
    end

    def self.pod_repo_push(path, module_name, source, version)
      Logger.highlight(%Q(Start Pod repo push #{module_name}))
      Dir.chdir(path) do
        command = ""
        if source.length > 0
          command = "pod repo push LPDSpecs #{module_name}.podspec --allow-warnings --sources=#{source} --verbose --use-libraries"
        else
          command = "pod repo push LPDSpecs #{module_name}.podspec --allow-warnings --verbose --use-libraries"
        end

        IO.popen("pod repo push LPDSpecs #{module_name}.podspec --allow-warnings --sources=#{source} --verbose --use-libraries") do |io|
          is_success = false
          error_info = Array.new
          io.each do |line|
            error_info.push(line)
            is_success = true if line.include? "Updating spec repo"
          end
          unless is_success
            puts error_info
            Logger.error("Fail: '#{module_name}' Pod repo fail")
          end
          Logger.highlight(%Q(Success release #{module_name} V#{version}))
        end
      end
    end

    def self.pod_update_private_repos
      Logger.highlight('Start pod repo update, waiting...')
      cmd = 'pod repo update LPDSpecs'
      Open3.popen3(cmd) do |stdin , stdout , stderr, wait_thr|
        while line = stdout.gets
          puts line
        end
      end
    end

  end
end
