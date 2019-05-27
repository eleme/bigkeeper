require 'big_keeper/command/pod/podfile'
require 'big_keeper/util/leancloud_logger'

module BigKeeper

  def self.pod_command
    desc 'Podfile operation'
    command :podfile do |podfile|
      podfile.desc 'Podfile'

      podfile.desc 'Detect podname should be locked.'
      podfile.command :detect do |detect|
        detect.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("podfile/detect")

          path = File.expand_path(global_options[:path])
          podfile_detect(path)
        end
      end

      podfile.desc 'Lock podname should be locked.'
      podfile.command :lock do |lock|
        lock.desc 'Lock pods accouding to Podfile.'
        lock.command :module do |m|
          m.action do |global_options, options, args|
            LeanCloudLogger.instance.set_command("podfile/lock/module")

            path = File.expand_path(global_options[:path])
            podfile_lock(path, false)
          end
        end
        lock.desc 'Lock pods accouding to Podfile.lock.'
        lock.command :submodule do |s|
          s.action do |global_options, options, args|
            LeanCloudLogger.instance.set_command("podfile/lock/submodule")

            path = File.expand_path(global_options[:path])
            podfile_lock(path, true)
          end
        end

      end

      podfile.desc 'Update modules should be upgrade.'
      podfile.command :update do |update|
        update.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("podfile/update")

          path = File.expand_path(global_options[:path])
          podfile_modules_update(path)
        end
      end
    end
  end
end
