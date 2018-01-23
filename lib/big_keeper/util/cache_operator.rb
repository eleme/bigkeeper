require 'fileutils'
require 'json'

module BigKeeper
  class CacheOperator
    def initialize(path)
      @path = File.expand_path(path)
      @cache_path = File.expand_path("#{path}/.bigkeeper")
    end

    def save(file)
      FileUtils.mkdir_p(@cache_path) unless File.exist?(@cache_path)
      FileUtils.cp("#{@path}/#{file}", "#{@cache_path}/#{file}");
    end

    def load(file)
      FileUtils.cp("#{@cache_path}/#{file}", "#{@path}/#{file}");
    end

    def clean
      FileUtils.rm_r(@cache_path)
    end
  end
end
