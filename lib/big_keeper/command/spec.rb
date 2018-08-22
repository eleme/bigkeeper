require 'big_keeper/command/spec/analyze'
require 'big_keeper/command/spec/list'
require 'big_keeper/command/spec/add'
require 'big_keeper/command/spec/delete'
require 'big_keeper/command/spec/search'

module BigKeeper

  def self.spec_command
    desc 'Spec operations'

    command :spec do |spec|
      spec.switch [:a,:all]
      spec.desc 'Analyze spec dependency infomation.'
      spec.command :analyze do |analyze|
        analyze.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          is_all = options[:all]
          module_names = args
          spec_analyze(path, is_all, module_names)
        end
      end

      spec.desc 'List all the specs.'
      spec.command :list do | list |
        list.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          spec_list(path, user, options)
        end
      end

      sepc.desc 'Sync Module dependency from Home.'
      spec.command :sync do | sync|
        sync.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase
          module_names = args

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
