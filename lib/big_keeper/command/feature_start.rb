#!/usr/bin/ruby

require './big_keeper/util/podfile_operator'
require './big_keeper/util/gitflow_operator'
require './big_keeper/service/stash_service'
require './big_keeper/util/bigkeeper_parser'
require './big_keeper/model/podfile_type'

module BigKeeper
  def self.start_new_feature(path, user, name, modules)
    # Parse Bigkeeper file
    BigkeeperParser.parse("#{path}/Bigkeeper")

    # Handle modules
    if modules
      # Verify input modules
      BigkeeperParser.verify_modules(modules)
    else
      # Get all modules if not specified
      modules = BigkeeperParser.module_names
      p modules
    end

    # Stash current branch
    StashService.new.stash(path, user)

    feature_name = "#{BigkeeperParser.version}_#{user}_#{name}"

    # Start modules feature
    modules.each do |module_name|
      module_path = BigkeeperParser.module_path(user, module_name)
      GitflowOperator.new.start_feature(module_path, name)
    end

    # Start home feature
    GitflowOperator.new.start_feature(path, name)

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

    # Open home workspace
    p `open #{path}/*.xcworkspace`

    # Cache new feature
    CacheOperator.new.cache_modules_for_branch('BigKeeperMain', '2.8.8_tom_fuck_xcode', ['LPDBigkeeperModular', 'LPDBigkeeperModular', 'LPDBigkeeperModular'])
  end
end
