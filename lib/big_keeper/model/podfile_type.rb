module BigKeeper
  module ModuleType
    PATH = 1
    GIT = 2
    SPEC = 3

    def self.regex(type)
      if PATH == type
        "\s*:path\s*=>\s*"
      elsif GIT == type
        "\s*:git\s*=>\s*"
      elsif SPEC == type
        "\s*'"
      else
        name
      end
    end
  end

  module GitType
    MASTER = 1
    BRANCH = 2
    TAG = 3
    COMMIT = 4
  end

  class GitInfo
    def initialize(base, type, addition)
      @base, @type, @addition = base, type, addition
    end

    def type
      @type
    end

    def base
      @base
    end

    def addition
      @addition
    end
  end
end
