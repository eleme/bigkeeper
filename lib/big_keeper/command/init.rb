require 'big_keeper/util/leancloud_logger'
require 'big_keeper/util/file_operator'
require 'fileutils'
require 'big_keeper/util/logger'

module BigKeeper
  def self.init_command
    desc 'BigKeeper file initialize'
    command :init do | c |
      c.desc "BigKeeper template file initialize."
      c.action do | global_options, options, args |
        LeanCloudLogger.instance.set_command("big/init")

        bin_path = File.dirname(__FILE__)
        bin_path = File.dirname(bin_path)
        bin_path = File.dirname(bin_path)
        bin_path = File.dirname(bin_path)
        path = global_options['path']
        Logger.highlight("Initialize BigKeeper File...")
        #template path
        source_file = File.join(bin_path, 'resources/template/BigKeeper')
        #BigKeeper file need exist path
        target_path = File.join(path, 'BigKeeper')

        if !File.exists?(target_path)
          FileUtils.cp(source_file, target_path)
          Logger.highlight("Initialize BigKeeper Complete!")
        else
          Logger.highlight("BigKeeper File Has Exist!")
        end

        LeanCloudLogger.instance.set_command("file/init")
      end
    end
  end
end
