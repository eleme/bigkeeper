module BigKeeper
  module GitflowType
    FEATURE = 1
    HOTFIX = 2
    RELEASE = 3

    def self.name(type)
      if FEATURE == type
        "feature"
      elsif HOTFIX == type
        "hotfix"
      elsif RELEASE == type
        "release"
      else
        "feature"
      end
    end

    def self.command(type)
      if FEATURE == type
        :feature
      elsif HOTFIX == type
        :hotfix
      elsif RELEASE == type
        :release
      else
        :feature
      end
    end

    def self.base_branch(type)
      if FEATURE == type
        "develop"
      elsif HOTFIX == type
        "master"
      elsif RELEASE == type
        "develop"
      else
        "master"
      end
    end
  end
end
