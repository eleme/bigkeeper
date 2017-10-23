#!/usr/bin/ruby

require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/service/stash_service'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/model/podfile_type'

module BigKeeper
  def self.feature_start(path, version, user, name, modules)
    begin
      # Parse Bigkeeper file
      BigkeeperParser.parse("#{path}/Bigkeeper")
      # Handle modules
      if modules
        # Verify input modules
        BigkeeperParser.verify_modules(modules)
      else
        # Get all modules if not specified
        modules = BigkeeperParser.module_names
      end

      version = BigkeeperParser.version if version == 'Version in Bigkeeper file'

      feature_name = "#{version}_#{user}_#{name}"

      if GitOperator.new.has_branch(path, "feature/#{feature_name}")
        raise %Q(Feature '#{feature_name}' already exists. Use 'feature switch' please)
      end

      # Stash current branch
      StashService.new.stash(path, "feature/#{feature_name}", user, modules)

      # Start modules feature
      modules.each do |module_name|
        module_path = BigkeeperParser.module_full_path(path, user, module_name)
        GitflowOperator.new.start_feature(module_path, feature_name)
        GitflowOperator.new.publish_feature(module_path, feature_name)
      end

      # Start home feature
      GitflowOperator.new.start_feature(path, feature_name)

      # Modify podfile as path
      current_path_type_modules = PodfileOperator.new.path_type_modules("#{path}/Podfile", BigkeeperParser.module_names)
      if modules != current_path_type_modules
        modules.each do |module_name|
          module_path = BigkeeperParser.module_path(user, module_name)
          PodfileOperator.new.find_and_replace("#{path}/Podfile",
                                               %Q('#{module_name}'),
                                               ModuleType::PATH,
                                               module_path)
        end

        # pod install
        p `pod install --project-directory=#{path}`

        # Push to remote
        if current_path_type_modules.empty?
          GitflowOperator.new.commit(path, "init feature #{feature_name}")
        else
          GitflowOperator.new.commit(path, %Q(update feature #{feature_name}'s modules with #{modules}))
        end
        GitflowOperator.new.publish_feature(path, feature_name)
      else
        p %Q(No updates for modules of feature '#{feature_name}', continue...)
      end

      # Open home workspace
      p `open #{path}/*.xcworkspace`
    ensure
    end
  end
end
