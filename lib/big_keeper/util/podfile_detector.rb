require '../util/param_parser'

params = BigKeeper::ParamParser.new.detect_podfile_unlock_items
main_path = File.expand_path(params[:main_path])

$modular_name_list = ["ELMKnightCollegeModule","LPDFoundationKit",
  "LPDIntelligentDispatchModular","LPDUserRelevanceModular",
  "LPDFeedbackModular","LPDQualityControlKit","LPDWalletModular",
  "LPDRiderClassificationModular","LPDTransferOrderModular",
  "LPDActivityModular","LPDPOIAddressService","LPDLogger"]

class PodfileDetector
  $unlock_pod_list = []
  def get_unlock_pod_list(main_path)
    podfile_lock_lines = File.readlines("#{main_path}/Podfile.lock")
    podfile_lines = File.readlines("#{main_path}/Podfile")
     p 'Analyzing Podfile...' unless podfile_lines.size.zero?
      podfile_lines.select do |sentence|
      deal_podfile_line(sentence) unless sentence =~(/\'[0-9]\.[0-9]\.[0-9]+\'/)
      end
      p $unlock_pod_list
  end

  def deal_podfile_line(sentence)
    if sentence.include?('pod ')
      pod_model = Podfile_Modle.new(sentence)
      if pod_model.name != nil
          $unlock_pod_list << pod_model.name unless modular_name_list.include?(pod_name)
      end
      return pod_model
    end
  end

  def get_pod_name(sentence)
    # match_data = /\'\w*\'/.match(sentence)
    # pod_name = match_data.to_a[0].delete('\'')
    pod_model = deal_podfile_line(sentence)
    pod_name = pod_model.name if pod_model != nil && pod_model.configurations.nil
    puts pod_name
    $unlock_pod_list << pod_name unless modular_name_list.include pod_name
  end

  def check_lock_version

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
          @git = $~.post_match
        elsif /:path =>/ =~ piece
          @path = $~.post_match
        elsif /:configurations =>/ =~ piece
          @configurations = $~.post_match
        elsif /:branch =>/ =~ piece
          @branch = $~.post_match
        elsif /:tag =>/ =~ piece
          @tag = $~.post_match
        elsif /pod /=~ piece
          @name = $~.post_match.delete "'\n "
        end
        #Debug p %Q{model name:#{@name},git:#{@git},path:#{@path},config:#{@configurations},branch:#{@branch},tag:#{@tag},comment:#{@comment}}
    end
  end
end

p params
p main_path
PodfileDetector.new.get_unlock_pod_list(main_path)
