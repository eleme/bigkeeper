require 'fileutils'
require 'json'

module BigKeeper
  class CacheOperator
    def initialize
      @cache_path = File.expand_path('~/.bigkeeper')
      @cache = {}

      FileUtils.mkdir_p(@cache_path) unless File.exist?(@cache_path)

      if File.exist?("#{@cache_path}/cache")
        file = File.open("#{@cache_path}/cache", 'r')
        @cache = JSON.load(file.read())
        file.close
      end
    end

    def modules_for_branch(home_name, branch_name)
      @cache[home_name][branch_name]
    end

    def branchs_for_home(home_name)
      @cache[home_name]
    end

    def cache_modules_for_branch(home_name, branch_name, modules)
      @cache[home_name] = {} if @cache[home_name].nil?
      @cache[home_name][branch_name] = modules
      file = File.new("#{@cache_path}/cache", 'w')
      file << @cache.to_json
      file.close
    end
  end

  # CacheOperator.new.cache_modules_for_branch('BigKeeperMain', '2.8.8_tom_fuck_xcode', ['LPDBigkeeperModular', 'LPDBigkeeperModular', 'LPDBigkeeperModular'])
  # p CacheOperator.new.modules_for_branch('BigKeeperMain', '2.8.8_tom_fuck_xcode')
  # CacheOperator.new.cache_modules_for_branch('BigKeeperMain', '2.8.8_tom_fuck_baby', ['LPDBigkeeperModular', 'LPDBigkeeperModular'])
  # p CacheOperator.new.modules_for_branch('BigKeeperMain', '2.8.8_tom_fuck_xcode')
  # p CacheOperator.new.modules_for_branch('BigKeeperMain', '2.8.8_tom_fuck_baby')
  # p CacheOperator.new.branchs_for_home('BigKeeperMain')
end
