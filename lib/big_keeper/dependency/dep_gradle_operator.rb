require 'big_keeper/dependency/dep_operator'

module BigKeeper
  # Operator for podfile
  class DepGradleOperator < DepOperator

    def backup
      CacheOperator.new(@path).save('lib/setting.gradle')
      CacheOperator.new(@path).save('build.gradle')
    end

    def recover
      cache_operator = CacheOperator.new(@path)
      cache_operator.load('lib/setting.gradle')
      cache_operator.load('build.gradle')
      cache_operator.clean
    end

    def modules_with_branch(modules, branch)

    end

    def modules_with_type(modules, type)

    end

    def find_and_replace(module_name, module_type, source)

    end

    def install(addition)
    end

    def open
    end
  end
end
