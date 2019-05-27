require 'colorize'
require 'big_keeper/util/leancloud_logger'

module BigKeeper
  DEFAULT_LOG = 1
  HIGHLIGHT_LOG = 2
  ERROR_LOG = 3
  WARNING_LOG = 4

  class Logger

    def self.log_with_type(sentence,type)
      case type
      when DEFAULT_LOG then puts sentence.to_s.colorize(:default)
      when HIGHLIGHT_LOG then puts sentence.to_s.colorize(:green)
      when ERROR_LOG then raise sentence.to_s.colorize(:red)
      when WARNING_LOG then puts sentence.to_s.colorize(:yellow)
      end
    end

    def self.default(sentence)
      puts formatter_output(sentence).colorize(:default)
    end

    def self.highlight(sentence)
      puts formatter_output(sentence).colorize(:green)
    end

    def self.error(sentence)
      is_need_log = LeanCloudLogger.instance.is_need_log
      LeanCloudLogger.instance.end_log(false, is_need_log)
      raise formatter_output(sentence).colorize(:red)
    end

    def self.warning(sentence)
      puts formatter_output(sentence).colorize(:yellow)
    end

    def self.separator
      puts "- - - - - - - - - - - - - - - - - - - - - - - - - - -".colorize(:light_blue)
    end

    def self.formatter_output(sentence)
      "[big] ".concat(sentence.to_s).to_s
    end
  end
end
