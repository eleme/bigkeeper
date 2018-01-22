require 'tempfile'
require 'fileutils'
require 'big_keeper/model/podfile_type'
require 'big_keeper/util/podfile_detector'

module BigKeeper
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

    def generate_pod_config(pod_name, version,comment)
      module_config = ''
      if comment != nil
        module_config = "  pod '#{pod_name}' , '#{version}' # #{comment}"
      else
        module_config =  "  pod '#{pod_name}' , '#{version}'"
      end
    end

    def replace_all_module_release(path, module_names, version)
      module_names.each do |module_name|
        DepService.dep_operator(path).find_and_replace(
                                             module_name,
                                             ModuleType::GIT,
                                             GitInfo.new(BigkeeperParser.module_git(module_name), GitType::TAG, version))
      end
    end

    def find_and_lock(podfile,dictionary)
      temp_file = Tempfile.new('.Podfile.tmp')
      begin
        File.open(podfile, 'r') do |file|
          file.each_line do |line|
            pod_model = PodfileDetector.get_pod_model(line)
            if pod_model != nil && pod_model.name != nil && dictionary[pod_model.name] != nil
                # p "#{pod_name},#{dictionary[pod_name]}"
                temp_file.puts generate_pod_config(pod_model.name,dictionary[pod_model.name],pod_model.comment)
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

    def find_and_upgrade(podfile,dictionary)
      temp_file = Tempfile.new('.Podfile.tmp')
      begin
        File.open(podfile, 'r') do |file|
          file.each_line do |line|
            pod_model = PodfileDetector.get_pod_model(line)
            if pod_model != nil && pod_model.name != nil && dictionary[pod_model.name] != nil
                temp_file.puts generate_pod_config(pod_model.name,dictionary[pod_model.name],pod_model.comment)
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

    def podspec_change(podspec_file, version, module_name)
      temp_file = Tempfile.new(".#{module_name}.podspec")
      begin
        File.open(podspec_file, 'r') do |file|
          file.each_line do |line|
            if line.include?("s.version")
              temp_line = line
              if temp_line.split("=")[0].delete(" ") == "s.version"
                temp_file.puts "s.version = '#{version}'"
              else
                temp_file.puts line
              end
            else
                temp_file.puts line
            end
          end
        end
        temp_file.close
        FileUtils.mv(temp_file.path, podspec_file)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    private :generate_module_config,:generate_pod_config
  end
end
