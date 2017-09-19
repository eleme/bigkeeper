module ModuleType
  PATH = 1
  GIT = 2
  SPEC = 3
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
