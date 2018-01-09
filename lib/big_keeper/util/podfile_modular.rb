require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/podfile_detector'
require 'big_keeper/model/podfile_model'
require 'big_keeper/util/logger'

module BigKeeper

class PodfileModularDetector
  @modular_list = []

  def initialize(main_path)
    @modular_list = BigkeeperParser.module_names
    @main_path = main_path
    @update_modules = {}
    # check_version_list
  end

  #检查需要更新业务库列表
  def check_version_list
    if @modular_list.empty?
      Logger.highlight('There is not any module should to be check.')
      return
    else
      Logger.highlight('Checking..')
      @modular_list.each do |modular_name|
        get_pod_search_result(modular_name)
      end

      #获得pod信息后
      deal_module_info
    end
  end


  # #找到本地repo
  # def find_source_repo(path)
  #   cocoapods_repo_path = File.expand_path('~')+'/.cocoapods/repos/'
  #   pn = Pathname.new(cocoapods_repo_path)
  #   pn.children.each do |pn|
  #     source_name = BigkeeperParser.source
  #     p pn.basename.to_s if pn.directory?
  #     Dir.entries(pn.dirname).select do |tag_dir|
  #       p tag_dir.to_s
  #     end
  #   end
  #   # Dir.entries(File.expand_path('~')+'/.cocoapods/repos/').select { |pn|
  #   #   p pn
  #   #  repo_name = File.basename(path)
  #   # }
  #
  # end

  def get_pod_search_result(pod_name)
    #输入pod Search 结果
    `pod search #{pod_name} --ios --simple >> #{@main_path}/bigKeeperPodInfo.tmp`
  end

  def deal_module_info
    podfile_lines = File.readlines("#{@main_path}/bigKeeperPodInfo.tmp")
    Logger.highlight("Analyzing modules info...") unless podfile_lines.size.zero?
      podfile_lines.collect do |sentence|
        if sentence =~(/pod/)
          sentence = sentence.sub('pod','')
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
