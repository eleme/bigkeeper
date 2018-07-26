require 'big_resources/util/image/name_analyze_util'

module BigKeeper
  def self.image_command
    desc 'Image operations'
    command :image do | c |
      c.desc "Detect duplicate name images."
      c.command :name do | name |
        name.action do | global_options, options, args |
          path = File.expand_path(global_options[:path])
          BigResources::ImageAnalyzeUtil.get_duplicate_name_file_with_type(path, BigResources::PNG)
        end
      end

      c.desc "Detect duplicate content images."
      c.command :content do | content |
        content.action do | global_options, options, args |
          path = File.expand_path(global_options[:path])
          BigResources::ImageAnalyzeUtil.get_duplicate_content_file_with_type(path, BigResources::PNG)
        end
      end
    end
  end
end
