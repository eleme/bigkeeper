require 'colorize'

module BigKeeper
  DEFAULT_LOG = 1
  HIGHLIGHT_LOG = 2
  ERROR_LOG = 3
  WARNING_LOG = 4

  class BigKeeperLog

    def self.log_with_type(sentence,type)
      case type
      when DEFAULT_LOG then puts sentence.to_s.colorize(:default)
      when HIGHLIGHT_LOG then puts sentence.to_s.colorize(:green)
      when ERROR_LOG then raise sentence.to_s.colorize(:red)
      when WARNING_LOG then puts sentence.to_s.colorize(:yellow)
      end
    end

    def self.default(sentence)
      puts sentence.to_s.colorize(:default)
    end

    def self.highlight(sentence)
      puts sentence.to_s.colorize(:green)
    end

    def self.error(sentence)
      raise sentence.to_s.colorize(:red)
    end

    def self.warning(sentence)
      puts sentence.to_s.colorize(:yellow)
    end

    def self.separator
      puts "- - - - - - - - - - - - - - - - - - - - - - - - - - -".colorize(:light_blue)
    end
  end
end
