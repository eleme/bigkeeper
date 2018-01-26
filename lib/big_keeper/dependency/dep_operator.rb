module BigKeeper
  # Operator for podfile
  class DepOperator
    @path

    def initialize(path)
      @path = path
    end

    def backup
      raise "You should override this method in subclass."
    end

    def recover
      raise "You should override this method in subclass."
    end

    def modules_with_branch(modules, branch_name)
      raise "You should override this method in subclass."
    end

    def modules_with_type(modules, type)
      raise "You should override this method in subclass."
    end

    def find_and_replace(module_name, module_type, source)
      raise "You should override this method in subclass."
    end

    def install(addition)
      raise "You should override this method in subclass."
    end

    def open
      raise "You should override this method in subclass."
    end
  end
end
