module BigKeeper
  class CommandLineUtil
    def self.double_check(tips)
      Logger.highlight("#{tips} (y/n)")
      input = STDIN.gets().chop
      input.eql?('y')
    end
  end
end
