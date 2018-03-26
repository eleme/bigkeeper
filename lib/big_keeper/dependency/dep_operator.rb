module BigKeeper
  # Operator for podfile
  class DepOperator
    @path
    @user

    def initialize(path, user)
      @path = path
      @user = user
    end

    def backup
      raise "You should override this method in subclass."
    end

    def recover
      raise "You should override this method in subclass."
    end

    def update_module_config(module_name, module_operate_type)
      raise "You should override this method in subclass."
    end

    def install(should_update)
      raise "You should override this method in subclass."
    end

    def open
      raise "You should override this method in subclass."
    end
  end
end
