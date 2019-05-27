require 'big_keeper/util/cache_operator'
require 'big_keeper/util/gradle_file_operator'
require 'big_keeper/util/bigkeeper_parser'

module BigKeeper
  # Operator for podfile
  class GradleModuleOperator
    @path
    @user
    @module_name

    BUILD_GRADLE = "build.gradle"
    SETTINGS_GRADLE = "settings.gradle"

    def initialize(path, user, module_name)
      @path = path
      @user = user
      @module_name = module_name
    end

    def backup
    end

    ## TODO
    def recover()
      module_full_path = BigkeeperParser.module_full_path(@path, @user, @module_name)
      source = BigkeeperParser.module_source(@module_name)
      build_file = "#{module_full_path}/#{source}/#{BUILD_GRADLE}"
      settings_file = "#{module_full_path}/#{SETTINGS_GRADLE}"
      GradleFileOperator.new(@path, @user).recover_bigkeeper_config_file(build_file)
      GradleFileOperator.new(@path, @user).recover_bigkeeper_config_file(settings_file)

      cache_operator = CacheOperator.new(module_full_path)
      cache_operator.clean
    end

    def update_module(module_operate_type)
        update_module_depends(module_operate_type)
        update_module_version_name(module_operate_type)
    end

    def update_module_depends(module_operate_type)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, @module_name)
      source = BigkeeperParser.module_source(@module_name)
      version_name = generate_version_name(module_operate_type)
      build_file = "#{module_full_path}/#{source}/#{BUILD_GRADLE}"
      settings_file = "#{module_full_path}/#{SETTINGS_GRADLE}"
      GradleFileOperator.new(@path, @user).update_module_depends(build_file, settings_file, @module_name, version_name)
    end

    def update_module_version_name(module_operate_type)
      module_full_path = BigkeeperParser.module_full_path(@path, @user, @module_name)
      source = BigkeeperParser.module_source(@module_name)
      GradleFileOperator.new(@path, @user).update_module_version_name("#{module_full_path}/#{source}/#{BUILD_GRADLE}", generate_version_name(module_operate_type))
    end

    def generate_version_name(module_operate_type)
      branch_name = GitOperator.new.current_branch(@path)
      version_name = ''
      if ModuleOperateType::ADD == module_operate_type
        version_name = branch_name.sub(/([\s\S]*)\/([\s\S]*)/){ $2 }
      elsif ModuleOperateType::FINISH == module_operate_type
        version_name = branch_name.sub(/([\s\S]*)\/(\d+.\d+.\d+)_([\s\S]*)/){ $2 }
      end
      return version_name
    end

  end
end
