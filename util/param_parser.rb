require 'optparse'

# Parser for parameters
class ParamParser
  def start_new_feature_parser
    params = {}
    OptionParser.new do |opts|
      opts.banner = 'Here is help messages of the start new feature command.'
      params[:mainpath] = './'
      opts.on('-m',
              '--mainpath=MainPath',
              'Path of the main project, end with /') do |main_path|
        params[:main_path] = main_path
      end
      opts.on('-n',
              '--modulename=ModuleName',
              'Name of the module in Podfile') do |module_name|
        params[:module_name] = module_name
      end
      opts.on('-p',
              '--modulepath=ModulePath',
              'Path of the module project') do |module_path|
        params[:module_path] = module_path
      end
      opts.on('-f',
              '--featurename=FeatureName',
              'Name of the new feature') do |feature_name|
        params[:feature_name] = feature_name
      end
    end.parse!

    raise OptionParser::MissingArgument if params[:module_name].nil?
    raise OptionParser::MissingArgument if params[:module_path].nil?
    raise OptionParser::MissingArgument if params[:feature_name].nil?

    params
  end

  def switch_to_debug_parser
    params = {}
    OptionParser.new do |opts|
      opts.banner = 'Here is help messages of the switch to debug command.'
      params[:mainpath] = './'
      opts.on('-m',
              '--mainpath=MainPath',
              'Path of the main project, end with /') do |main_path|
        params[:main_path] = main_path
      end
      opts.on('-n',
              '--modulename=ModuleName',
              'Name of the module in Podfile') do |module_name|
        params[:module_name] = module_name
      end
      opts.on('-p',
              '--modulepath=ModulePath',
              'Path of the module project') do |module_path|
        params[:module_path] = module_path
      end
    end.parse!

    raise OptionParser::MissingArgument if params[:module_name].nil?
    raise OptionParser::MissingArgument if params[:module_path].nil?

    params
  end

  def switch_to_push_parser
    params = {}
    OptionParser.new do |opts|
      opts.banner = 'Here is help messages of the switch to debug command.'
      params[:mainpath] = './'
      opts.on('-m',
              '--mainpath=MainPath',
              'Path of the main project, end with /') do |main_path|
        params[:main_path] = main_path
      end
      opts.on('-n',
              '--modulename=ModuleName',
              'Name of the module in Podfile') do |module_name|
        params[:module_name] = module_name
      end
      opts.on('-g',
              '--gitbase=GitBase',
              'Git base URL of the module project') do |git_base|
        params[:git_base] = git_base
      end
      opts.on('-f',
              '--featurename=FeatureName',
              'Name of the new feature') do |feature_name|
        params[:feature_name] = feature_name
      end
    end.parse!

    raise OptionParser::MissingArgument if params[:module_name].nil?
    raise OptionParser::MissingArgument if params[:git_base].nil?
    raise OptionParser::MissingArgument if params[:feature_name].nil?

    params
  end
end
