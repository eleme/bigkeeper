require 'big_keeper/command/release/home'
require 'big_keeper/command/release/module'
require 'big_keeper/util/leancloud_logger'
require 'big_keeper/command/release/start'
require 'big_keeper/command/release/finish'
require 'big_keeper/util/command_line_util'

module BigKeeper
  def self.release_command
    desc 'Gitflow release operations'
    command :release do |c|

      c.desc 'release project start'
      c.command :start do |start|
        start.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          modules = args[(0...args.length)] if args.length > 0
          release_start(path, version, user, modules)
        end
      end

      c.desc 'release project finish'
      c.command :finish do |finish|
        finish.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          modules = args[(0...args.length)] if args.length > 0
          release_finish(path, version, user, modules)
        end
      end

      c.desc 'Release home project operations'
      c.command :home do |home|
        home.desc 'Start release home project'
        home.command :start do |start|
          start.action do |global_options, options, args|
            path = File.expand_path(global_options[:path])
            version = global_options[:ver]
            user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
            LeanCloudLogger.instance.set_command("release/home/start")

            help_now!('user name is required') if user and user.empty?
            raise Logger.error("release version is required") if version == nil
            release_home_start(path, version, user)
          end
        end

        home.desc 'Finish release home project'
        home.command :finish do |finish|
          finish.action do |global_options, options, args|
            path = File.expand_path(global_options[:path])
            version = global_options[:ver]
            LeanCloudLogger.instance.set_command("release/home/finish")

            raise Logger.error("release version is required") if version == nil
            release_home_finish(path, version)
          end
        end
      end

      c.desc 'release module'
      c.switch [:i,:ignore]
      c.command :module do |m|
        m.desc 'Start release module project'
        m.command :start do |start|
          start.action do |global_options, options, args|
            path = File.expand_path(global_options[:path])
            version = global_options[:ver]
            user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
            LeanCloudLogger.instance.set_command("release/module/start")

            help_now!('module name is required') if args.length != 1
            raise Logger.error("release version is required") if version == nil
            module_name = args[0]
            release_module_start(path, version, user, module_name, options[:ignore])
          end
        end

        m.desc 'finish release module project'
        m.switch [:s,:spec]
        m.command :finish do |finish|
          finish.action do |global_options, options, args|
            path = File.expand_path(global_options[:path])
            version = global_options[:ver]
            user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
            LeanCloudLogger.instance.set_command("release/module/finish")

            help_now!('module name is required') if args.length != 1
            raise Logger.error("release version is required") if version == nil
            module_name = args[0]
            release_module_finish(path, version, user, module_name, options[:spec])
          end
        end
      end
    end
  end
end
