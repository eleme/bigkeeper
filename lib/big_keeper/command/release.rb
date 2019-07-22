require 'big_keeper/command/release/home'
require 'big_keeper/command/release/module'
require 'big_keeper/util/leancloud_logger'
require 'big_keeper/command/release/start'
require 'big_keeper/util/command_line_util'

module BigKeeper
  def self.release_command

    desc 'Release home project & module.'
    command :prerelease do |c|
      c.desc 'Prerelease home project.'
      c.command :home do |home|
        home.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("prerelease/home")
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          modules = args[(0...args.length)] if args.length > 0
          prerelease(path, version, user, modules)
        end
      end

      c.desc 'if ignore warning'
      c.switch [:i,:ignore]
      c.desc 'Release single module operations'
      c.command :module do |m|
        m.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("prerelease/module")
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          help_now!('module name is required') if args.length == 0
          raise Logger.error("release version is required") if version == nil
          modules = args[(0...args.length)] if args.length > 0
          prerelease_module(path, version, user, modules, false)
        end
      end
    end

    desc 'Gitflow release operations'
    command :release do |c|
      c.action do |global_options, options, args|
        LeanCloudLogger.instance.set_command("release")
        path = File.expand_path(global_options[:path])
        version = global_options[:ver]
        user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
        modules = args[(0...args.length)] if args.length > 0
        release(path, version, user, modules)
      end

      c.desc 'if ignore warning'
      c.switch [:i,:ignore]
      c.desc 'Release single module operations'
      c.command :module do |m|
        m.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          LeanCloudLogger.instance.set_command("release/module")

          help_now!('module name is required') if args.length == 0
          raise Logger.error("release version is required") if version == nil
          modules = args[(0...args.length)] if args.length > 0
          release_module(path, version, user, modules, options[:spec])
        end
      end
    end
  end
end
