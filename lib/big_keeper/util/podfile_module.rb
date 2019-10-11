require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/podfile_detector'
require 'big_keeper/model/podfile_model'
require 'big_keeper/util/logger'

module BigKeeper

class PodfileModuleDetector
  @module_list = []

  def initialize(main_path)
    @module_list = BigkeeperParser.module_names
    @main_path = main_path
    @update_modules = {}
    # check_version_list
  end

  #检查需要更新业务库列表
  def check_version_list
    if @module_list.empty?
      Logger.highlight('There is not any module should to be check.')
      return
    else
      Logger.highlight('Checking..')
      @module_list.each do |module_name|
        get_pod_search_result(module_name)
      end

      #获得pod信息后
      deal_module_info
    end
  end

  def get_pod_search_result(pod_name)
    #输入pod Search 结果
    `pod search #{pod_name} --ios --simple >> #{@main_path}/bigKeeperPodInfo.tmp`
  end

  def deal_module_info
    podfile_lines = File.readlines("#{@main_path}/bigKeeperPodInfo.tmp", :encoding => 'UTF-8')
    Logger.highlight("Analyzing modules info...") unless podfile_lines.size.zero?
      podfile_lines.collect do |sentence|
        if sentence =~(/pod/)
          sentence = sentence.sub('pod', '')
          sentence = sentence.delete('\n\'')
          match_result = sentence.split(',')
          pod_name = match_result[0].strip
          latest_version = match_result[1].strip
          @update_modules[pod_name] = latest_version  unless @update_modules.include?(pod_name)
        end
      end
    p @update_modules
    File.delete("#{@main_path}/bigKeeperPodInfo.tmp")
    @update_modules
  end

  def get_module_latest_version(pod_model)

  end

end

end
