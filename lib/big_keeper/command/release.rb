require 'big_keeper/command/release/home'
require 'big_keeper/command/release/module'

module BigKeeper
  def self.release_command
    desc 'Gitflow release operations'
    command :release do |c|

      c.desc 'Release home project operations'
      c.command :home do |home|
        home.desc 'Start release home project'
        home.command :start do |start|
          start.action do |global_options, options, args|
            help_now!('user name is required') if user and user.empty?
            raise Logger.error("release version is required") if version == nil
            release_home_start(path, version, user)
          end
        end

        home.desc 'Finish release home project'
        home.command :finish do |finish|
          finish.action do |global_options, options, args|
            raise Logger.error("release version is required") if version == nil
            release_home_finish(path, version)
          end
        end
      end

      c.desc 'release module'
      c.command :module do |m|
        m.desc 'Start release module project'
        m.command :start do |start|
          start.action do |global_options, options, args|
            help_now!('module name is required') if args.length != 1
            raise Logger.error("release version is required") if version == nil
            module_name = args[0]
            release_module_start(path, version, user, module_name)
          end
        end

        m.desc 'finish release module project'
        m.command :finish do |finish|
          finish.action do |global_options, options, args|
            help_now!('module name is required') if args.length != 1
            raise Logger.error("release version is required") if version == nil
            module_name = args[0]
            release_module_finish(path, version, user, module_name)
          end
        end
      end
    end
  end
end
