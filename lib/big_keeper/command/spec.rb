require 'big_keeper/command/spec/analyze'
require 'big_keeper/command/spec/add'
require 'big_keeper/command/spec/delete'
require 'big_keeper/command/spec/search'

module BigKeeper

  def self.spec_command
    desc 'spec command'

    command :spec do |spec|
      spec.switch [:a,:all]
      spec.command :analyze do |analyze|
        analyze.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          is_all = options[:all]
          module_names = args
          spec_analyze(path, is_all, module_names)
        end
      end
      spec.command :add do |add|
        add.action do
          spec_add()
        end
      end
      spec.command :delete do |delete|
        delete.action do
          spec_delete()
        end
      end
      spec.command :search do |search|
        search.action do
          spec_search()
        end
      end

    end
  end
end
