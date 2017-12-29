require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/model/podfile_model'
require 'big_keeper/util/logger'
require 'big_keeper/util/repo_detector'

module BigKeeper

class PodfileModularDetector
  @modular_list = []

  def initialize(main_path)
    @modular_list = BigkeeperParser.module_names
    @main_path = main_path
    check_version_list
  end

  #检查需要更新业务库列表
  def check_version_list
    if @modular_list.empty?
      Logger.highlight('There is nothing to be check.')
      return
    else
      Logger.highlight('Checking..')
      source = check_modular_source
      p source
      @modular_list.each do |modular_name|
        check_latest_version(modular_name)
        find_source_repo(modular_name)
      end
    end
  end

  def check_modular

  end
  #检查配置文件中是否有配置业务模块source
  def check_modular_source
    module_source = BigkeeperParser::sourcemodule_path
    p module_source
  end

  #找到本地repo
  def find_source_repo(path)
    cocoapods_repo_path = File.expand_path('~')+'/.cocoapods/repos/'
    pn = Pathname.new(cocoapods_repo_path)
    pn.children.each do |pn|
      source_name = BigkeeperParser.source
      p pn.basename.to_s if pn.directory?
      Dir.entries(pn.dirname).select do |tag_dir|
        p tag_dir.to_s
      end
    end
    # Dir.entries(File.expand_path('~')+'/.cocoapods/repos/').select { |pn|
    #   p pn
    #  repo_name = File.basename(path)
    # }

  end

  def check_latest_version(name)
    Logger.default(name)
    check_modular_source
  end



end

end
