
require 'tempfile'
require 'fileutils'
require '../model/podfile_type'

# Operator for podfile
class PodfileOperator
  def has(podfile, module_name)
    File.open(podfile, 'r') do |file|
      file.each_line do |line|
        if line.include?module_name
          return true
        end
      end
    end
    false
  end

  def find_and_replace(podfile, module_name, module_type, source)
    temp_file = Tempfile.new('.Podfile.tmp')

    begin
      File.open(podfile, 'r') do |file|
        file.each_line do |line|
          if line.include?module_name
            temp_file.puts generate_module_config(module_name, module_type, source)
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

  def generate_module_config(module_name, module_type, source)
    module_config = ''
    if ModuleType::PATH == module_type
      module_config = %Q(  pod #{module_name}, :path => '#{source}')
    elsif ModuleType::GIT == module_type
      if GitType::BRANCH == source.type
        module_config = %Q(  pod #{module_name}, :git => '#{source.base}', :branch => '#{source.addition}')
      elsif GitType::TAG == source.type
        module_config = %Q(  pod #{module_name}, :git => '#{source.base}', :tag => '#{source.addition}')
      elsif GitType::COMMIT == source.type
        module_config = %Q(  pod #{module_name}, :git => '#{source.base}', :commit => '#{source.addition}')
      else
        module_config = %Q(  pod #{module_name}, :git => '#{source.base}')
      end
    else
      module_config = %Q(  pod #{module_name}, '#{source}')
    end
    module_config
  end

  private :generate_module_config
end
