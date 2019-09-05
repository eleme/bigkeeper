require 'big_keeper/util/leancloud_logger'
require 'big_keeper/command/pod/podfile'
require 'big_keeper/command/spec/list'
require 'big_keeper/util/list_generator'

module BigKeeper

  def self.client_command
    desc 'API for bigkeeper-client.'
    command :client do | c |
      c.desc 'Commands about operate modules.'
      c.command :modules do |modules|
        modules.desc 'Get modules list from Bigkeeper file.'
        modules.command :list do |list|
            list.action do |global_options, options, args|
            LeanCloudLogger.instance.set_command("spec/list")
            path = File.expand_path(global_options[:path])
            version = global_options[:ver]
            user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
            spec_list(path, user, options)
          end
        end
        modules.desc 'Update modules.'
        modules.command :update do |update|
          update.action do |global_options, options, args|
            LeanCloudLogger.instance.set_command("spec/list")
            path = File.expand_path(global_options[:path])
            version = global_options[:ver]
            user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
            spec_list(path, user, options)
          end
        end
      end
      c.desc 'Commands about features.'
      c.command :feature do |feature|
        feature.desc "List all the features including origin."
        feature.command :list do | list |
            list.flag %i[v version] , default_value: 'all versions'
            list.action do |global_options, options, args|
              LeanCloudLogger.instance.set_command("feature/list/json")
              options[:json] = true
              path = File.expand_path(global_options[:path])
              user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
              list(path, user, GitflowType::FEATURE, options)
          end
        end
      end
    end
  end
end
