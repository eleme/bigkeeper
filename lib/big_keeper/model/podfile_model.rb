
module BigKeeper

class Podfile_Modle
  attr_accessor :name, :git, :path, :configurations, :branch,:tag, :comment
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
end
