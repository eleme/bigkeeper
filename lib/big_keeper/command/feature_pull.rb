module BigKeeper
  def self.feature_pull(path, user)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      branch_name = GitOperator.new.current_branch(path)
      raise 'Not a feature branch, exit.' unless branch_name.include? 'feature'

      modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                                      BigkeeperParser.module_names, ModuleType::PATH)

      modules.each do |module_name|
        ModuleService.new.pull(path, user, module_name, branch_name)
      end

      p "Pull branch #{branch_name} for home..."
      GitOperator.new.pull(path, branch_name)
    ensure
    end
  end
end
