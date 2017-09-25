$config = {}
$current_user = ''

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

def home(name, params)
  users = $config[:users]
  user = users[$current_user]
  user[:home] = params
  $config[:users] = users
end

def pod(name, params)
  if params[:path]
    users = $config[:users]
    user = users[$current_user]
    pods = user[:pods]
    pods = {} if pods == nil
    pods[name] = params
    user[:pods] = pods
    $config[:users] = users
  elsif params[:git]
    modules = $config[:modules]
    modules[name] = params
    $config[:modules] = modules
  else
    raise %Q(There should be ':path =>' or ':git =>' for pod #{name})
  end
end

def modules
  modules = $config[:modules]
  modules = {} if modules == nil
  $config[:modules] = modules
  yield if block_given?
end

class ConfigParser
  def initialize
    content = File.read '/Users/mmoaay/Documents/eleme/BigKeeperMain/Bigkeeper'
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

  def get_module_git(module_name)
    $config[:modules][module_name][:git]
  end

  def get_modules
    $config[:modules].keys
  end

  def get_config
    $config
  end
end

p ConfigParser.new.get_home_path('perry')
p ConfigParser.new.get_module_path('perry', 'BigKeeperModular')
p ConfigParser.new.get_module_git('BigKeeperModular')
p ConfigParser.new.get_modules
