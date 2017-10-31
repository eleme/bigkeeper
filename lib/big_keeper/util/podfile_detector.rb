require '../util/param_parser'

params = BigKeeper::ParamParser.new.detect_podfile_unlock_items
main_path = File.expand_path(params[:main_path])

$modular_name_list = ["ELMKnightCollegeModule","LPDFoundationKit",
  "LPDIntelligentDispatchModular","LPDUserRelevanceModular",
  "LPDFeedbackModular","LPDQualityControlKit","LPDWalletModular",
  "LPDRiderClassificationModular","LPDTransferOrderModular",
  "LPDActivityModular","LPDPOIAddressService"]

class PodfileDetector

  $unlock_pod_list = []
  $modify_pod_list = {}
  def get_unlock_pod_list(main_path)
    podfile_lines = File.readlines("#{main_path}/Podfile")
     p 'Analyzing Podfile...' unless podfile_lines.size.zero?
      podfile_lines.collect do |sentence|
      deal_podfile_line(sentence) unless sentence =~(/\'\d+.\d+.\d+'/)
      end
      p $unlock_pod_list
      $modify_pod_list = deal_lock_file(main_path,$unlock_pod_list)
      p $modify_pod_list
  end

  def deal_podfile_line(sentence)
    if sentence.include?('pod ')
      pod_model = Podfile_Modle.new(sentence)
      # p pod_model
      if !pod_model.name.empty? && pod_model.configurations != '[\'Debug\']' && pod_model.path == nil && pod_model.tag == nil
          $unlock_pod_list << pod_model.name unless $modular_name_list.include?(pod_model.name)
      end
      return pod_model
    end
  end

  def get_pod_name(sentence)
    # match_data = /\'\w*\'/.match(sentence)
    # pod_name = match_data.to_a[0].delete('\'')
    pod_model = deal_podfile_line(sentence)
    pod_name = pod_model.name if pod_model != nil && pod_model.configurations.nil
    # puts pod_name
    $unlock_pod_list << pod_name unless modular_name_list.include pod_name
  end

  def deal_lock_file(main_path,deal_list)
      $result = {}
      podfile_lock_lines = File.readlines("#{main_path}/Podfile.lock")
      p 'Analyzing Podfile.lock...' unless podfile_lock_lines.size.zero?
      podfile_lock_lines.select do |sentence|

      if sentence.include?('DEPENDENCIES')  #指定范围解析 Dependencies 之前
        break
      end

      temp_sentence = sentence.strip
      pod_name = get_lock_podname(temp_sentence)
      # p pod_name
      if deal_list.include?(pod_name)
        current_version = $result[pod_name]
        temp_version = get_lock_version(temp_sentence)
        if temp_version != nil
          if current_version != nil
            # p "cur_version #{current_version} temp_version #{temp_version}"
            $result[pod_name] = chose_version(current_version,temp_version)
          else
            $result[pod_name] = temp_version
          end
        end
      end
    end
      return $result
  end

  def get_lock_podname(sentence) #获得pod名称
    # p sentence.delete('- :~>=')
    match_result = /(\d+.\d+.\d+)|(\d+.\d+)/.match(sentence.delete('- :~>='))
    pod_name = match_result.pre_match unless match_result == nil
    return pod_name.delete('(') unless pod_name == nil
  end

  def get_lock_version(sentence)#获得pod版本号
     sentence.scan(/\d+.\d+.\d+/) do |version|
      return version
     end
     return nil
  end

  def chose_version(cur_version,temp_version)
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

class Podfile_Modle
  attr_accessor :name,:git,:path,:configurations,:branch,:tag,:comment
  def initialize(sentence)
    if sentence.include?('#')
      list = sentence.split('#')
      @comment = list[1]
      sentence = list[0]
    end

    sentence_slip_list = sentence.split(',')
    return if sentence_slip_list.size.zero?
    for piece in sentence_slip_list do
        if /:git =>/ =~ piece
          @git = $~.post_match.strip
        elsif /:path =>/ =~ piece
          @path = $~.post_match.strip
        elsif /:configurations =>/ =~ piece
          @configurations = $~.post_match.strip
        elsif /:branch =>/ =~ piece
          @branch = $~.post_match.strip
        elsif /:tag =>/ =~ piece
          @tag = $~.post_match.strip
        elsif /pod /=~ piece
          @name = $~.post_match.delete("'\n ")
        end
      #  p %Q{model name:#{@name},git:#{@git},path:#{@path},config:#{@configurations},branch:#{@branch},tag:#{@tag},comment:#{@comment}}
    end
  end
end

# p params
# p main_path
PodfileDetector.new.get_unlock_pod_list(main_path)
