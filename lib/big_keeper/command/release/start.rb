module BigKeeper
  def self.release_start(path, version, user, modules)
    DepService.dep_operator(path, user).release_start(path, version, user, modules)
  end

  def self.release_check_changed_modules(path, user)
    changed_modules = []
    BigkeeperParser.parse("#{path}/Bigkeeper")
    allModules = BigkeeperParser.module_names
    allModules.each do |module_name|
      if ModuleService.new.release_check_changed(path, user, module_name)
        changed_modules << module_name
      end
    end
    changed_modules
  end
  
end
