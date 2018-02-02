require 'big_keeper/command/pod/podfile'

module BigKeeper

  def self.pod_command
    desc 'Podfile operation'
    command :podfile do |podfile|
      podfile.flag %i[pod podfile]
      podfile.desc 'Podfile'
      path = ''

      podfile.desc 'Detect podname should be locked.'
      podfile.command :detect do |detect|
        detect.action do |global_options,options,args|
          podfile_detect(path)
        end
      end

      podfile.desc 'Lock podname should be locked.'
      podfile.command :lock do |lock|
        lock.action do |global_options, options, args|
          podfile_lock(path)
        end
      end

      podfile.desc 'Update modules should be upgrade.'
      podfile.command :update do |lock|
        lock.action do |global_options, options, args|
          podfile_modules_update(path)
        end
      end
    end
  end
end
