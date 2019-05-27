require 'fileutils'
require 'json'

module BigKeeper
  class CacheOperator
    def initialize(path)
      @path = File.expand_path(path)
      @cache_path = File.expand_path("#{path}/.bigkeeper")
    end

    def save(file)
      dest_path = File.dirname("#{@cache_path}/#{file}")
      FileUtils.mkdir_p(dest_path) unless File.exist?(dest_path)
      FileUtils.cp("#{@path}/#{file}", "#{@cache_path}/#{file}");
    end

    def load(file)
      FileUtils.cp("#{@cache_path}/#{file}", "#{@path}/#{file}");
    end

    def clean
      if File.exist?(@cache_path)
        FileUtils.rm_r(@cache_path)
      end
    end
  end

  class ModuleCacheOperator
    def initialize(path)
      @cache_path = File.expand_path("#{path}/.bigkeeper")

      FileUtils.mkdir_p(@cache_path) unless File.exist?(@cache_path)

      if File.exist?("#{@cache_path}/module.cache")
        file = File.open("#{@cache_path}/module.cache", 'r')
        @modules = JSON.load(file.read())
        file.close
      else
        @modules = {"git" => {"all" => [], "current" => []}, "path" => {"all" => [], "add" => [], "del" => [], "current" => []}}
      end
    end

    def all_path_modules
      @modules["path"]["all"]
    end

    def add_path_modules
      @modules["path"]["add"]
    end

    def del_path_modules
      @modules["path"]["del"]
    end

    def current_path_modules
      @modules["path"]["current"]
    end

    def remain_path_modules
      @modules["path"]["all"] - @modules["path"]["current"]
    end

    def all_git_modules
      @modules["git"]["all"]
    end

    def current_git_modules
      @modules["git"]["current"]
    end

    def remain_git_modules
      @modules["git"]["all"] - @modules["git"]["current"]
    end

    def cache_path_modules(modules, add_modules, del_modules)
      @modules["path"]["all"] = modules.uniq
      @modules["path"]["add"] = add_modules.uniq
      @modules["path"]["del"] = del_modules.uniq
      cache_modules
    end

    def cache_git_modules(modules)
      @modules["git"]["all"] = modules.uniq
      cache_modules
    end

    def add_git_module(module_name)
      @modules["git"]["current"] << module_name unless @modules["git"]["current"].include?(module_name)
      cache_modules
    end

    def del_git_module(module_name)
      @modules["git"]["current"].delete(module_name) if @modules["git"]["current"].include?(module_name)
      cache_modules
    end

    def add_path_module(module_name)
      @modules["path"]["current"] << module_name unless @modules["path"]["current"].include?(module_name)
      cache_modules
    end

    def del_path_module(module_name)
      @modules["path"]["current"].delete(module_name) if @modules["path"]["current"].include?(module_name)
      cache_modules
    end

    def clean_modules
      @modules = {"git" => {"all" => [], "current" => []}, "path" => {"all" => [], "add" => [], "del" => [], "current" => []}}
      cache_modules
    end

    def cache_modules
      file = File.new("#{@cache_path}/module.cache", 'w')
      file << @modules.to_json
      file.close
    end
  end
end
