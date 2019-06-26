require 'tempfile'
require 'fileutils'
require 'big_keeper/dependency/dep_type'
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

    def generate_pod_config(pod_name, version, comment)
      module_config = ''
      if comment != nil
        module_config = "  pod '#{pod_name}' , '#{version}' # #{comment}"
      else
        module_config =  "  pod '#{pod_name}' , '#{version}'"
      end
    end

    def replace_all_module_release(path, user, module_names, version)
      module_names.each do |module_name|
        DepService.dep_operator(path, user).update_module_config(
                                             module_name,
                                             ModuleOperateType::RELEASE)
      end

    end

    def find_and_lock(podfile, dictionary)
      temp_file = Tempfile.new('.Podfile.tmp', :encoding => 'UTF-8')
      begin
        File.open(podfile, 'r') do |file|
          file.each_line do |line|
            pod_model = PodfileParser.get_pod_model(line)
            if pod_model != nil && pod_model.name != nil && dictionary[pod_model.name] != nil
                temp_file.puts generate_pod_config(pod_model.name, dictionary[pod_model.name], pod_model.comment)
                dictionary.delete(pod_model.name)
            else
                temp_file.puts line
            end
          end
        end
        if !dictionary.empty?
          temp_file.puts 'def sub_dependency'
          dictionary.keys.each do |sub_pod|
            temp_file.puts generate_pod_config(sub_pod, dictionary[sub_pod], 'bigkeeper')
          end
          temp_file.puts 'end'
        end
        temp_file.close
        FileUtils.mv(temp_file.path, podfile)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def find_and_upgrade(podfile, dictionary)
      temp_file = Tempfile.new('.Podfile.tmp', :encoding => 'UTF-8')
      begin
        File.open(podfile, 'r', :encoding => 'UTF-8') do |file|
          file.each_line do |line|
            pod_model = PodfileParser.get_pod_model(line)
            if pod_model != nil && pod_model.name != nil && dictionary[pod_model.name] != nil
                #替换
                temp_file.puts generate_pod_config(pod_model.name, dictionary[pod_model.name], pod_model.comment)
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
      temp_file = Tempfile.new(".#{module_name}.podspec", :encoding => 'UTF-8')
      has_change = false
      begin
        File.open(podspec_file, 'r', :encoding => 'UTF-8') do |file|
          file.each_line do |line|
            if line.include?("s.version")
              temp_line = line
              temp_line_arr = temp_line.split("=")
              if temp_line_arr[0].delete(" ") == "s.version"
                unless temp_line_arr[temp_line_arr.length - 1].include? "#{version}"
                    temp_file.puts "s.version = '#{version}'"
                    has_change = true
                else
                    temp_file.puts line
                    Logger.highlight("The version in PodSpec is equal your input version")
                end
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
      has_change
    end

    private :generate_pod_config
  end
end
