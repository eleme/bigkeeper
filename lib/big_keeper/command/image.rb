require 'big_resources/stash_operator'

module BigKeeper

  def self.module_command

    desc 'Image operation'
    command :image do | c |
      c.desc "Detect duplicate name images."
        c.command :name do | name |
          name.action do | global_options, options, args |
            path = File.expand_path(global_options[:path])
            ImageAnalyzeUtil.get_duplicate_name_file_with_type(path, PNG)
          end
        end

        c.desc "Detect duplicate content images."
        c.command :content do | content |
          content.action do | global_options, options, args |
            path = File.expand_path(global_options[:path])
            ImageAnalyzeUtil.get_duplicate_content_file_with_type(path, PNG)
          end
        end
    end
  end
end
