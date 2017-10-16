$config = {}
$current_user = ''

def build(name)
  $config[:build] = name
end

def version(name)
  $config[:version] = name
end

def user(name)
  $current_user = name
  users = $config[:users]
  users = {} if users == nil
  users[name] = {}
  $config[:users] = users
  yield if block_given?
end

def home(params)
  users = $config[:users]
  user = users[$current_user]
  user[:home] = params
  $config[:users] = users
end

def pod(name, params)
  users = $config[:users]
  user = users[$current_user]
  pods = user[:pods]
  pods = {} if pods == nil
  pods[name] = params
  user[:pods] = pods
  $config[:users] = users
end

def modules(modules)
  $config[:modules] = modules
end

class ConfigParser
  def initialize
    content = File.read '/Users/SFM/Downloads/BigKeeperMain-master/Bigkeeper'
    eval content
    $current_user = ''

    p $config
  end

  def get_home_path(user_name)
    $config[:users][user_name][:home][:path]
  end

  def get_module_path(user_name, module_name)
    $config[:users][user_name][:pods][module_name][:path]
  end

  def get_module_git(user_name, module_name)
    $config[:users][user_name][:pods][module_name][:git]
  end

  def get_config
    $config[:target]
  end
end

p ConfigParser.new.get_home_path('perry')
# p ConfigParser.new.get_module_path('perry', 'BigKeeperModular')
# p ConfigParser.new.get_module_git('perry', 'BigKeeperModular')
