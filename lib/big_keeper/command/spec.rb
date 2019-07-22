require 'big_keeper/command/spec/analyze'
require 'big_keeper/command/spec/list'
require 'big_keeper/command/spec/add'
require 'big_keeper/command/spec/delete'
require 'big_keeper/command/spec/search'
require 'big_keeper/command/spec/sync'
require 'big_keeper/util/leancloud_logger'

module BigKeeper

  def self.spec_command
    desc 'Spec operations'

    command :spec do |spec|
      spec.switch [:a,:all]
      spec.desc 'Analyze spec dependency infomation.'
      spec.command :analyze do |analyze|
        analyze.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("spec/analyze")

          path = File.expand_path(global_options[:path])
          is_all = options[:all]
          module_names = args
          spec_analyze(path, is_all, module_names)
        end
      end

      spec.desc 'List all the specs.'
      spec.command :list do | list |
        list.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("spec/list")

          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          spec_list(path, user, options)
        end
      end

      spec.desc 'Sync Module dependency from Home.'
      spec.command :sync do | sync|
        sync.action do |global_options, options, args|
          LeanCloudLogger.instance.set_command("spec/sync")
          path = File.expand_path(global_options[:path])
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          help_now!('module name is required') if args.length != 1
          module_name = args[0]
          spec_sync(path, user, module_name)
        end
      end

      spec.desc 'Add a spec (Coming soon).'
      spec.command :add do |add|
        add.action do
          spec_add()
        end
      end

      spec.desc 'Delete a spec (Coming soon).'
      spec.command :delete do |delete|
        delete.action do
          spec_delete()
        end
      end

      spec.desc 'Search a spec with name (Coming soon).'
      spec.command :search do |search|
        search.action do
          spec_search()
        end
      end

    end
  end
end
