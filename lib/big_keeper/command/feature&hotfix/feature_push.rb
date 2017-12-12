require 'big_keeper/util/logger'

module BigKeeper

  def self.feature_push(path, user, comment)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      branch_name = GitOperator.new.current_branch(path)
      Logger.error("Not a feature branch, exit.") unless branch_name.include? 'feature'

      modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                BigkeeperParser.module_names, ModuleType::PATH)

      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        module_branch_name = GitOperator.new.current_branch(module_full_path)

        Logger.highlight("Push branch '#{branch_name}' for module '#{module_name}'...")
        GitService.new.verify_push(module_full_path, comment, module_branch_name, module_name)
      end

      Logger.highlight("Push branch '#{branch_name}' for 'Home'...")
      GitService.new.verify_push(path, comment, branch_name, 'Home')
    ensure
    end
  end
end
