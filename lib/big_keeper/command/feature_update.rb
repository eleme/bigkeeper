#!/usr/bin/ruby

require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/util/bigkeeper_parser'

require './big_keeper/model/podfile_type'

require './big_keeper/service/stash_service'
require './big_keeper/service/module_service'


module BigKeeper
  def self.feature_update(path, version, user, name, modules)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")

      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
      feature_name = "#{version}_#{user}_#{name}"
      branch_name = "#{GitflowType.name(GitflowType::FEATURE)}/#{feature_name}"

      GitService.new.verify_branch(path, branch_name, OperateType::UPDATE)

      current_modules = PodfileOperator.new.modules_with_type("#{path}/Podfile",
                                BigkeeperParser.module_names, ModuleType::PATH)

      # Handle modules
      if modules
        # Verify input modules
        BigkeeperParser.verify_modules(modules)
      else
        # Get all modules if not specified
        modules = BigkeeperParser.module_names
      end

      add_modules = modules - current_modules
      del_modules = current_modules - modules

      if add_modules.empty? and del_modules.empty?
        p "There is nothing changed with modules #{modules}."
      else
        # Modify podfile as path and Start modules feature
        add_modules.each do |module_name|
          ModuleService.new.add(path, user, module_name, feature_name, GitflowType::FEATURE)
        end

        del_modules.each do |module_name|
          ModuleService.new.del(path, user, module_name, feature_name, GitflowType::FEATURE)
        end

        # pod install
        p `pod install --project-directory=#{path}`

        # Open home workspace
        p `open #{path}/*.xcworkspace`
      end
    ensure
    end
  end
end
