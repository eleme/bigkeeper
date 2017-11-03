module BigKeeper

  def self.feature_push(path, user, comment)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      branch_name = GitOperator.new.current_branch(path)
      raise "Not a feature branch, exit." unless branch_name.include? 'feature'

      modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                BigkeeperParser.module_names, ModuleType::PATH)

      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        module_branch_name = GitOperator.new.current_branch(module_full_path)

        if GitOperator.new.has_changes(module_full_path)
          p "Push branch #{branch_name} for module #{module_name}..."
          GitOperator.new.commit(module_full_path, comment)
          GitOperator.new.push(module_full_path, module_branch_name)
        else
          p "Nothing to push for #{module_name}."
        end
      end

      if GitOperator.new.has_changes(path)
        p "Push branch #{branch_name} for home..."
        GitOperator.new.commit(path, comment)
        GitOperator.new.push(path, branch_name)
      else
        p "Nothing to push for home."
      end
    ensure
    end
  end
end
