require 'big_keeper/util/logger'

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

  def self.pod(name, params)
    BigkeeperParser.parse_pod(name, params)
  end

  def self.modules
    BigkeeperParser.parse_modules
    yield if block_given?
  end

  def self.source(name)
    BigkeeperParser.parse_source(name)
  end

  # Bigkeeper file parser
  class BigkeeperParser
    @@config = {}
    @@current_user = ''

    def self.parse(bigkeeper)
      if @@config.empty?

        Logger.error("Can't find a Bigkeeper file in current directory.") if !BigkeeperParser.definitely_exists?(bigkeeper)

        content = File.read bigkeeper
        content.gsub!(/version\s/, 'BigKeeper::version ')
        content.gsub!(/user\s/, 'BigKeeper::user ')
        content.gsub!(/home\s/, 'BigKeeper::home ')
        content.gsub!(/pod\s/, 'BigKeeper::pod ')
        content.gsub!(/modules\s/, 'BigKeeper::modules ')
        content.gsub!(/source\s/, 'BigKeeper::source ')
        eval content
        # p @@config
      end
    end

    def self.definitely_exists? path
      folder = File.dirname path
      filename = File.basename path
      # Unlike Ruby IO, ls, and find -f, this technique will fail to locate the file if the case is wrong:
      not %x( find "#{folder}" -name "#{filename}" ).empty?
    end

    def self.parse_version(name)
      @@config[:version] = name
    end

    def self.parse_source(name)
      sources = []
      sources << @@config[:source]
      sources << name
      @@config[:source] = sources
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

    def self.parse_pod(name, params)
      if params[:path]
        parse_user_pod(name, params)
      elsif params[:git]
        parse_modules_pod(name, params)
      else
        Logger.error(%(There should be ':path =>' or ':git =>' for pod #{name}))
      end
    end

    def self.parse_user_pod(name, params)
      users = @@config[:users]
      user = users[@@current_user]
      pods = user[:pods]
      pods = {} if pods.nil?
      pods[name] = params
      user[:pods] = pods
      @@config[:users] = users
    end

    def self.parse_modules_pod(name, params)
      modules = @@config[:modules]
      modules[name] = params
      @@config[:modules] = modules
    end

    def self.parse_modules
      modules = @@config[:modules]
      modules = {} if modules.nil?
      @@config[:modules] = modules
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

    def self.sourcemodule_path
      if @@config[:source] == nil
        return ""
      else
        @@config[:source].join(",").reverse.chop.reverse
      end
    end

    def self.module_full_path(home_path, user_name, module_name)
      if @@config[:users] \
        && @@config[:users][user_name] \
        && @@config[:users][user_name][:pods] \
        && @@config[:users][user_name][:pods][module_name] \
        && @@config[:users][user_name][:pods][module_name][:path]
        @@config[:users][user_name][:pods][module_name][:path]
      else
        File.expand_path("#{home_path}/../#{module_name}")
      end
    end

    def self.module_path(user_name, module_name)
      if @@config[:users] \
        && @@config[:users][user_name] \
        && @@config[:users][user_name][:pods] \
        && @@config[:users][user_name][:pods][module_name] \
        && @@config[:users][user_name][:pods][module_name][:path]
        @@config[:users][user_name][:pods][module_name][:path]
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
      modules.each do |item|
        Logger.error("Can not find module #{item} in Bigkeeper file") unless @@config[:modules][item]
      end
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
