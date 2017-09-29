module BigKeeper
  def self.version(name)
    ConfigParser.parse_version(name)
  end

  def self.user(name)
    ConfigParser.parse_user(name)
    yield if block_given?
  end

  def self.home(_name, params)
    ConfigParser.parse_home(params)
  end

  def self.pod(name, params)
    ConfigParser.parse_pod(name, params)
  end

  def self.modules
    ConfigParser.parse_modules
    yield if block_given?
  end

  # Bigkeeper file parser
  class ConfigParser
    @@config = {}
    @@current_user = ''

    def self.parse(bigkeeper)
      content = File.read bigkeeper

      content.gsub!(/version\s/, 'BigKeeper::version ')
      content.gsub!(/user\s/, 'BigKeeper::user ')
      content.gsub!(/home\s/, 'BigKeeper::home ')
      content.gsub!(/pod\s/, 'BigKeeper::pod ')
      content.gsub!(/modules\s/, 'BigKeeper::modules ')

      eval content
      p @@config
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

    def self.parse_home(params)
      users = @@config[:users]
      user = users[@@current_user]
      user[:home] = params
      @@config[:users] = users
    end

    def self.parse_pod(name, params)
      if params[:path]
        parse_user_pod(name, params)
      elsif params[:git]
        parse_modules_pod(name, params)
      else
        raise %(There should be ':path =>' or ':git =>' for pod #{name})
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

    def self.home_path(user_name)
      @@config[:users][user_name][:home][:path]
    end

    def self.module_path(user_name, module_name)
      @@config[:users][user_name][:pods][module_name][:path]
    end

    def self.module_git(module_name)
      @@config[:modules][module_name][:git]
    end

    def self.module_names
      @@config[:modules].keys
    end

    def self.config
      @@config
    end
  end

  ConfigParser.parse('/Users/mmoaay/Documents/eleme/BigKeeperMain/Bigkeeper')

  p ConfigParser.home_path('perry')
  p ConfigParser.module_path('perry', 'BigKeeperModular')
  p ConfigParser.module_git('BigKeeperModular')
  p ConfigParser.module_names
end
