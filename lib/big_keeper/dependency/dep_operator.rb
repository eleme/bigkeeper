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

    def prerelease_start(path, version, user, modules)
      raise "You should override this method in subclass."
    end

    def prerelease_finish(path, version, user, modules)
      raise "You should override this method in subclass."
    end

    def prerelease_home_start(path, version, user, modules)
      raise "You should override this method in subclass."
    end

    def prerelease_home_finish(path, version, user, modules)
      raise "You should override this method in subclass."
    end

    def release_module_start(modules, module_name, version)
      raise "You should override this method in subclass."
    end

    def release_module_finish(modules, module_name, version)
      raise "You should override this method in subclass."
    end

    def release_home_start(path, version, user, modules)
      raise "You should override this method in subclass."
    end

    def release_home_finish(path, version, user, modules)
      raise "You should override this method in subclass."
    end

    def install(modules, type, should_update)
      raise "You should override this method in subclass."
    end

    def open
      raise "You should override this method in subclass."
    end
  end
end
