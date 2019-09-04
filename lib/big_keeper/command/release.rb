require 'big_keeper/command/release/home'
require 'big_keeper/command/release/module'
require 'big_keeper/util/leancloud_logger'
require 'big_keeper/command/release/start'
require 'big_keeper/util/command_line_util'

module BigKeeper
  def self.release_command
    desc 'Release home project & module.'
    command :release do |c|
      c.desc 'Prerelease home project.'
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
            modules = args[(0...args.length)] if args.length > 0
            release_home_start(path, version, user, modules)
          end
        end

        home.desc 'Finish release home project'
        home.command :finish do |finish|
          finish.action do |global_options, options, args|
            path = File.expand_path(global_options[:path])
            version = global_options[:ver]
            user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
            LeanCloudLogger.instance.set_command("release/home/finish")

            help_now!('user name is required') if user and user.empty?
            raise Logger.error("release version is required") if version == nil
            release_home_finish(path, version, user, modules)
          end
        end
      end

      c.desc 'if ignore warning'
      c.switch [:i,:ignore]
      c.desc 'Release single module operations'
      c.command :module do |m|
        m.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("release/module")
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          help_now!('module name is required') if args.length == 0
          raise Logger.error("release version is required") if version == nil
          modules = args[(0...args.length)] if args.length > 0
          release_module(path, version, user, modules, options[:spec])
        end
      end
    end
  end
end
