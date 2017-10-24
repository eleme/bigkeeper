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
        name
      end
    end
  end
end
