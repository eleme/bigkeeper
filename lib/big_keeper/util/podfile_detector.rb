require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/model/podfile_model'
require 'big_keeper/util/logger'
require 'Singleton'
module BigKeeper

class PodfileParser
  include Singleton
  attr_accessor :module_list, :main_path, :pod_list
  $unlock_pod_list = []
  $modify_pod_list = {}

  def initialize
    @module_list = BigkeeperParser.module_names
    @pod_list = []
  end

  def parse(path)
    @main_path = path
    podfile_lines = File.readlines("#{@main_path}/Podfile")
    Logger.highlight("Analyzing Podfile...") unless podfile_lines.size.zero?
    podfile_lines.collect do |sentence|
      if /pod / =~ sentence
        pod_name = get_pod_name(sentence)
        @pod_list << pod_name
      end
    end
  end

  def get_unlock_pod_list
    podfile_lines = File.readlines("#{@main_path}/Podfile")
    Logger.highlight("Analyzing Podfile...") unless podfile_lines.size.zero?
    podfile_lines.collect do |sentence|
    deal_podfile_line(sentence) unless sentence =~(/(\d+.){1,2}\d+/)
    end
    $unlock_pod_list
  end

  def deal_podfile_line(sentence)
    return unless !sentence.strip.start_with?("#")
    if sentence.strip.include?('pod ')
      pod_model = PodfileModel.new(sentence)
      if !pod_model.name.empty? &&
         pod_model.configurations != '[\'Debug\']' &&
         pod_model.path == nil &&
         pod_model.tag == nil
            pod_names = pod_model.name.split('/')
            if pod_names.size > 1
              pod_name = pod_names[0]
            else
              pod_name = pod_model.name
            end
            $unlock_pod_list << pod_name unless @module_list.include?(pod_name)
      end
      pod_model
    end
  end

  def get_pod_name(sentence)
    pod_model = deal_podfile_line(sentence)
    if pod_model != nil
      return pod_model.name
    end
  end

  def self.get_pod_model(sentence)
    if sentence.include?('pod ')
      pod_model = PodfileModel.new(sentence)
      return pod_model
    end
  end

  def get_lock_podname(sentence) #获得pod名称
    match_result = /(\d+.){1,2}\d+/.match(sentence.delete('- :~>='))
    pod_name = match_result.pre_match unless match_result == nil
    return pod_name.delete('()') unless pod_name == nil
  end

  def get_lock_version(sentence)#获得pod版本号
    match_result = /(\d+.){1,2}\d+/.match(sentence)
    return match_result[0] unless match_result == nil
  end

  def chose_version(cur_version,temp_version)
    # p "cur:#{cur_version},temp:#{temp_version}"
    cur_list = cur_version.split('.')
    temp_list = temp_version.split('.')
    temp_list << 0.to_s if temp_list.size == 2
    if cur_list[0] >= temp_list[0]
      if cur_list[1] >= temp_list[1]
        if cur_list[2] > temp_list[2]
          return cur_version
        end
        return temp_version
      end
      return temp_version
    end
    return temp_version
  end
end
end
