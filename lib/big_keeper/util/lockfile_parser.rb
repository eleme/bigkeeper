require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/logger'
require 'big_keeper/util/podfile_detector'
require 'Singleton'

module BigKeeper
  class LockfileParser
    include Singleton
    attr_accessor :main_path, :dependencies, :pods, :podfile_hash
    $mode = 'PODS'

    def initialize
      self.pods = {}
      self.dependencies = []
    end

    def parse(main_path)
      self.main_path = main_path
      $mode = 'PODS'
      podfile_lock_lines = File.readlines("#{main_path}/Podfile.lock")
      Logger.highlight("Analyzing Podfile.lock...")
      podfile_lock_lines.each do |sentence|
        if sentence.include?('PODS')
          $mode = 'PODS'
        elsif sentence.include?('DEPENDENCIES')
          $mode = 'DEPENDENCIES'
        elsif sentence.include?('SPEC REPOS')
          $mode = 'SPEC REPOS'
        elsif sentence.include?('SPEC CHECKSUMS')
          $mode = 'SPEC CHECKSUMS'
        elsif sentence.include?('CHECKOUT OPTIONS')
          $mode = 'CHECKOUT OPTIONS'
        elsif sentence.include?('EXTERNAL SOURCES')
          $mode = 'EXTERNAL SOURCES'
        elsif sentence.include?('PODFILE CHECKSUM')
          $mode = 'PODFILE CHECKSUM'
        else
          if $mode == 'PODS'
             deal_pod(sentence)
          end
          if $mode == 'SPEC CHECKSUMS'
             deal_spec(sentence)
          end
        end
       end
     end

     def get_unlock_pod_list(is_all)
       result = {}
       pod_parser = PodfileParser.instance
       #podfile 中 unlock pods
       unlock_pods = pod_parser.get_unlock_pod_list
       # @unlock_pod_list << pod_name unless @module_list.include pod_name

       if is_all
         self.dependencies.each do |pod_name|
           if pod_parser.pod_list.include?(pod_name)
             next
           end
           if self.pods[pod_name] != nil
             result[pod_name] = self.pods[pod_name]
           end
         end

         unlock_pods.each do |pod_name|
           if self.pods[pod_name] != nil
             result[pod_name] = self.pods[pod_name]
           end
         end
         # print(result)
         return result
       else
         return unlock_pods
       end
     end

    #处理PODS
    # TODO 去除重复
    def deal_pod(s)
      pod_name = get_lock_podname(s.strip)
      pod_version = get_lock_version(s.strip)
      if self.pods.keys.include?(pod_name)
        current_version = self.pods[pod_name]
        if pod_version != nil
          if current_version != nil
            self.pods[pod_name] = chose_version(current_version, pod_version)
          else
            self.pods[pod_name] = pod_version
          end
        end
      else
        self.pods[pod_name] = pod_version
      end
    end
    #
    # #处理EXTERNAL SOURCES
    # def deal_sources(s)
    #
    # end
    # #处理CHECKOUT OPTIONS
    # def deal_checkout(s)
    #
    # end

    #处理SPEC CHECKSUMS
    def deal_spec(s)
        if /: +/ =~ s
        dependency = $~.pre_match.strip
        self.dependencies << dependency unless self.dependencies.include?(dependency)
        end
    end

    def get_lock_podname(sentence) #获得lock pod名称
      match_result = /(\d+.){1,2}\d+/.match(sentence.delete('- :~>='))
      pod_name = match_result.pre_match unless match_result == nil
      return pod_name.delete('()') unless pod_name == nil
    end

    def get_lock_version(sentence)#获得lock pod版本号
      match_result = /(\d+.){1,2}\d+/.match(sentence)
      return match_result[0] unless match_result == nil
    end

    def chose_version(cur_version,temp_version)
      # p "cur:#{cur_version},temp:#{temp_version}"
      cur_list = cur_version.split('.')
      temp_list = temp_version.split('.')
      cur_list << 0.to_s if cur_list.size == 2
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
