require 'big_keeper/command/module/list'

module BigKeeper

  def self.module_command

    desc 'Module operation'
    command :module do | mod |

      mod.desc 'module'
      mod.desc 'Prase module relevant infomation.'
      mod.command :list do | list |
        list.action do |global_options, options, args|
          path = File.expand_path(global_options[:path])
          version = global_options[:ver]
          user = global_options[:user].gsub(/[^0-9A-Za-z]/, '').downcase

          module_list(path, user, options)
        end
      end
    end
  end
end
