require 'big_keeper/util/logger'
require 'big_keeper/util/file_operator'

# Bigkeeper module
module BigKeeper
  def self.version(name)
    BigkeeperParser.parse_version(name)
  end

  def self.user(name)
    BigkeeperParser.parse_user(name)
    yield if block_given?
  end

  def self.home(name, params)
    BigkeeperParser.parse_home(name, params)
  end

  def self.mod(name, params)
    BigkeeperParser.parse_mod(name, params)
  end

  def self.modules
    BigkeeperParser.parse_modules
    yield if block_given?
  end

  def self.source(name)
    BigkeeperParser.parse_source(name)
    yield if block_given?
  end

  def self.globalConfig
    BigkeeperParser.parse_global_config
    yield if block_given?
  end

  def self.config(key, value)
    BigkeeperParser.parse_config(key, value)
    yield if block_given?
  end

  # Bigkeeper file parser
  class BigkeeperParser
    @@config = {}
    @@current_user = ''

    def self.parse(bigkeeper)
      if @@config.empty?

        Logger.error("Can't find a Bigkeeper file in current directory.") if !FileOperator.definitely_exists?(bigkeeper)

        content = File.read bigkeeper
        content.gsub!(/version\s/, 'BigKeeper::version ')
        content.gsub!(/user\s/, 'BigKeeper::user ')
        content.gsub!(/home\s/, 'BigKeeper::home ')
        content.gsub!(/source\s/, 'BigKeeper::source ')
        content.gsub!(/mod\s/, 'BigKeeper::mod ')
        content.gsub!(/modules\s/, 'BigKeeper::modules ')
        content.gsub!(/global_config\s/, 'BigKeeper::globalConfig ')
        content.gsub!(/config\s/, 'BigKeeper::config ')
        eval content
      end
    end

    def self.parse_source(name)
      @@config.delete("tmpSpec")
      source_split = name.split(",") unless name.split(",").length != 2
      if source_split != nil
        sources = Hash["#{source_split[1].lstrip}" => "#{source_split[0]}"]
        @@config[:source] = sources
        @@config[:tmpSpec] = source_split[1].lstrip
      end
    end

    def self.parse_version(name)
      @@config[:version] = name
    end

    def self.parse_user(name)
      @@current_user = name
      users = @@config[:users]
      users = {} if users.nil?
      users[name] = {}
      @@config[:users] = users
    end

    def self.parse_home(name, params)
      @@config[:home] = params
      @@config[:name] = name
    end

    def self.parse_mod(name, params)
      if params[:path]
        parse_user_mod(name, params)
      elsif params[:git]
        parse_modules_mod(name, params)
      else
        Logger.error(%(There should be ':path =>' or ':git =>' for mod #{name}))
      end
    end

    def self.parse_user_mod(name, params)
      users = @@config[:users]
      user = users[@@current_user]
      mods = user[:mods]
      mods = {} if mods.nil?
      mods[name] = params
      user[:mods] = mods
      @@config[:users] = users
    end

    def self.parse_modules_mod(name, params)
      if @@config[:source] != nil
          params[:spec] = "#{@@config[:tmpSpec]}"
      end
      modules = @@config[:modules]
      modules[name] = params
      @@config[:modules] = modules
    end

    def self.parse_modules
      modules = @@config[:modules]
      modules = {} if modules.nil?
      @@config[:modules] = modules
    end

    def self.parse_global_config
      @@config[:globalConfig] = {}
    end

    def self.parse_config(key, value)
      @@config[:globalConfig] = @@config[:globalConfig].merge(key => value)
    end

    def self.version
      @@config[:version]
    end

    def self.home_name
      @@config[:name]
    end

    def self.home_git()
      @@config[:home][:git]
    end

    def self.home_pulls()
      @@config[:home][:pulls]
    end

    def self.source_spec_path(module_name)
      spec = @@config[:modules][module_name][:spec]
      @@config[:source][spec]
    end

    def self.source_spec_name(module_name)
      spec = @@config[:modules][module_name][:spec]
    end

    def self.sources
      @@config[:source].keys
    end

    def self.global_config(key)
      @@config[:globalConfig][key]
    end

    def self.module_full_path(home_path, user_name, module_name)
      if @@config[:users] \
        && @@config[:users][user_name] \
        && @@config[:users][user_name][:mods] \
        && @@config[:users][user_name][:mods][module_name] \
        && @@config[:users][user_name][:mods][module_name][:path]
        @@config[:users][user_name][:mods][module_name][:path]
      else
        File.expand_path("#{home_path}/../#{module_name}")
      end
    end

    def self.module_path(user_name, module_name)
      if @@config[:users] \
        && @@config[:users][user_name] \
        && @@config[:users][user_name][:mods] \
        && @@config[:users][user_name][:mods][module_name] \
        && @@config[:users][user_name][:mods][module_name][:path]
        @@config[:users][user_name][:mods][module_name][:path]
      else
        "../#{module_name}"
      end
    end

    def self.module_git(module_name)
      @@config[:modules][module_name][:git]
    end

    def self.module_pulls(module_name)
      @@config[:modules][module_name][:pulls]
    end

    def self.verify_modules(modules)
      modules = [] unless modules
      modules = modules.uniq
      modules.each do |item|
        Logger.error("Can not find module #{item} in Bigkeeper file") unless @@config[:modules][item]
      end
      modules
    end

    def self.module_names
      @@config[:modules].keys
    end

    def self.config
      @@config
    end
  end

  # BigkeeperParser.parse('/Users/mmoaay/Documents/eleme/BigKeeperMain/Bigkeeper')
  # BigkeeperParser.parse('/Users/mmoaay/Documents/eleme/BigKeeperMain/Bigkeeper')
  #
  # p BigkeeperParser.home_git()
  # p BigkeeperParser.home_pulls()
  # p BigkeeperParser.module_path('perry', 'BigKeeperModular')
  # p BigkeeperParser.module_path('', 'BigKeeperModular')
  # p BigkeeperParser.module_git('BigKeeperModular')
  # pulls = BigkeeperParser.module_pulls('BigKeeperModular')
  # `open #{pulls}`
  # p BigkeeperParser.module_names
end
