
require 'tempfile'
require 'fileutils'

# Operator for podfile
class PodfileOperator
  def self.find(podfile, module_name)
    File.open(podfile, 'r') do |file|
      file.each_line do |line|
        if line.include?module_name
          return true
        end
      end
    end
    false
  end

  def self.find_and_replace(podfile, origin, replacement)
    temp_file = Tempfile.new('.Podfile.tmp')
    begin
      File.open(podfile, 'r') do |file|
        file.each_line do |line|
          if line.include?origin
            matched = true
            temp_file.puts replacement
          else
            temp_file.puts line
          end
        end
      end
      temp_file.close
      FileUtils.mv(temp_file.path, podfile)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end
end
