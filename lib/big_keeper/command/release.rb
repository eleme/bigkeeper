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
        start.desc 'Start release home project'
        start.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("release/start")
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          modules = args[(0...args.length)] if args.length > 0
          release_start(path, version, user, modules)
        end
      end

      c.desc 'release project finish'
      c.command :finish do |finish|
        finish.desc 'Finish release home project'
        finish.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("release/finish")
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          modules = args[(0...args.length)] if args.length > 0
          release_finish(path, version, user, modules)
        end
      end

      c.desc 'if ignore warning'
      c.switch [:i,:ignore]
      c.desc 'Release single module operations'
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

        m.desc 'pod publish to spec'
        m.switch [:s,:spec]
        m.desc 'finish release module project'
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
