require 'big_keeper/util/logger'
require 'open3'

module BigKeeper
  class PodOperator
    def self.pod_install(path, repo_update)
      # pod install
      if repo_update
        PodOperator.pod_update_private_repos(true)
      end
      Logger.highlight('Start pod install, waiting...')
      cmd = "pod install --project-directory='#{path}'"
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        while line = stdout.gets
          p line
        end
      end
      Logger.highlight('Finish pod install.')
    end

    def self.pod_repo_push(path, module_name, source, version)
      Logger.highlight(%Q(Start Pod repo push #{module_name}))
      Dir.chdir(path) do
        command = ""
        p BigkeeperParser.source_spec_name(module_name)
        if source.length > 0
          command = "pod repo push #{BigkeeperParser.source_spec_name(module_name)} #{module_name}.podspec --allow-warnings --sources=#{source} --verbose --use-libraries"
        else
          command = "pod repo push #{BigkeeperParser.source_spec_name(module_name)} #{module_name}.podspec --allow-warnings --verbose --use-libraries"
        end

        IO.popen(command) do |io|
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

    def self.pod_update_private_repos(update_private)
      if update_private
        BigkeeperParser.sources.map { |spec|
          Logger.highlight('Start pod repo update, waiting...')
          cmd = "pod repo update #{spec}"
          cmd(cmd)
        }
      else
        cmd = "pod repo update"
        cmd(cmd)
      end
    end

    def self.cmd(cmd)
      Open3.popen3(cmd) do |stdin , stdout , stderr, wait_thr|
        while line = stdout.gets
          puts line
        end
      end
    end

  end
end
