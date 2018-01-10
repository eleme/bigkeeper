require 'big_keeper/util/logger'

module BigKeeper
  def self.pull(path, user, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      branch_name = GitOperator.new.current_branch(path)

      Logger.error("Not a #{GitflowType.name(type)} branch, exit.") unless branch_name.include? GitflowType.name(type)

      modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                                      BigkeeperParser.module_names, ModuleType::PATH)

      modules.each do |module_name|
        ModuleService.new.pull(path, user, module_name, branch_name, type)
      end

      Logger.highlight("Pull branch '#{branch_name}' for 'Home'...")
      GitOperator.new.pull(path)
    ensure
    end
  end
end
