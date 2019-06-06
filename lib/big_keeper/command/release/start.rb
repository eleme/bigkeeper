module BigKeeper
  def self.release_start(path, version, user, modules)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
    modules = release_check_changed_modules(path, user) if (modules.nil? || modules.empty?)

    if modules.nil? || modules.empty?
      Logger.error('no module need to release')
    end

    if !CommandLineUtil.double_check("module #{modules} will changed version to #{version}-SNAPSHOT, are you sure?")
      Logger.error('release start interrupt')
    end

    #stash home
    StashService.new.stash(path, GitOperator.new.current_branch(path), 'home')
    # delete cache
    CacheOperator.new(path).clean()
    # checkout develop
    GitService.new.verify_checkout_pull(path, 'develop')

    modules.each do |module_name|
      Logger.highlight("release start module #{module_name}")
      ModuleService.new.release_start(path, user, modules, module_name, version)
    end

    #release home
    DepService.dep_operator(path, user).release_home_start(modules, version)

    # Push home changes to remote
    Logger.highlight("Push branch 'develop' for 'Home'...")
    GitService.new.verify_push(
      path,
      "release start for #{version}",
      'develop',
      'Home')
  end

  def self.release_finish(path, version, user, modules)
    BigkeeperParser.parse("#{path}/Bigkeeper")
    version = BigkeeperParser.version if version == 'Version in Bigkeeper file'

    #stash home
    StashService.new.stash(path, GitOperator.new.current_branch(path), 'home')
    # delete cache
    CacheOperator.new(path).clean()
    # checkout develop
    GitService.new.verify_checkout_pull(path, 'develop')

    modules.each do |module_name|
      Logger.highlight("release start module #{module_name}")
      ModuleService.new.release_finish(path, user, modules, module_name, version)
    end

    #release home
    DepService.dep_operator(path, user).release_home_finish(modules, version)

    # Push home changes to remote
    Logger.highlight("Push branch 'develop' for 'Home'...")
    GitService.new.verify_push(
      path,
      "release finish for #{version}",
      'develop',
      'Home')
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
