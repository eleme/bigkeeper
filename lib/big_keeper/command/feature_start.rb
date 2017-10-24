#!/usr/bin/ruby

require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/service/stash_service'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/model/podfile_type'

module BigKeeper
  def self.feature_start(path, user, name, modules)
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

      feature_name = "#{BigkeeperParser.version}_#{user}_#{name}"

      # Stash current branch
      if GitOperator.new.current_branch(path) != "feature/#{feature_name}"
        StashService.new.stash(path, user, modules)
      end

      # Start modules feature
      modules.each do |module_name|
        module_path = BigkeeperParser.module_full_path(path, user, module_name)
        GitflowOperator.new.start_feature(module_path, feature_name)
      end

      # Start home feature
      GitflowOperator.new.start_feature(path, feature_name)

      # Modify podfile as path
      modules.each do |module_name|
        module_path = BigkeeperParser.module_path(user, module_name)
        PodfileOperator.new.find_and_replace(%Q(#{path}/Podfile),
                                             %Q('#{module_name}'),
                                             ModuleType::PATH,
                                             module_path)
      end

      # pod install
      p `pod install --project-directory=#{path}`

      # Push to remote
      GitflowOperator.new.commit(path, "init feature #{feature_name}")
      GitflowOperator.new.publish_feature(path, feature_name)

      # Cache new feature
      CacheOperator.new.cache_modules_for_branch(BigkeeperParser.home_name,
                                                 GitOperator.new.current_branch(path),
                                                 modules)

      # Open home workspace
      p `open #{path}/*.xcworkspace`
    ensure
    end
  end
end
