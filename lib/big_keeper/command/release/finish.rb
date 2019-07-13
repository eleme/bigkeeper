module BigKeeper
  def self.release_finish(path, version, user, modules)
    DepService.dep_operator(path, user).release_finish(path, version, user, modules)
  end
end
