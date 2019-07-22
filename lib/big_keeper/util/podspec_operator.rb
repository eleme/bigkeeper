require 'tempfile'
require 'fileutils'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/podfile_detector'

module BigKeeper
  # Operator for podspec file
  class PodspecOperator
    include Singleton
    attr_accessor :module_list, :main_path, :pod_list
    $unlock_pod_list = []
    $modify_pod_list = {}

    def initialize
      @module_list = BigkeeperParser.module_names
      @pod_list = []
    end

    def parse(path, module_name)
      @main_path = path
      podspec_lines = File.readlines("#{@main_path}/#{module_name}.podspec", :encoding => 'UTF-8')
      Logger.highlight("Analyzing Podspec...") unless podspec_lines.size.zero?
      podspec_lines.collect do |sentence|
        if /dependency / =~ sentence
          pod_name = get_pod_name(sentence)
          @pod_list << pod_name
        end
      end
    end

    def get_pod_name(sentence)
      pod_model = deal_podfile_line(sentence)
      if pod_model != nil
        return pod_model.chomp.gsub("'", "")
      end
    end

    def deal_podfile_line(sentence)
      pod_name = ''
      if sentence.strip.include?('dependency ')
        pod_dep = sentence.split('dependency ')
        if pod_dep.size > 1
          pod_names = pod_dep[1].split(',')
          if pod_names.size > 1
            pod_name = pod_names[0]
          else
            pod_name = pod_dep[1]
          end
        end
        pod_name
      end
    end

  end
end
