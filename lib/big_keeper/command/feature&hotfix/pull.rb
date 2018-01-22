require 'big_keeper/util/logger'

require 'big_keeper/dependency/dep_service'

module BigKeeper
  def self.pull(path, user, type)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      branch_name = GitOperator.new.current_branch(path)

      Logger.error("Not a #{GitflowType.name(type)} branch, exit.") unless branch_name.include? GitflowType.name(type)

      modules = DepService.dep_operator(path).modules_with_type(
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
