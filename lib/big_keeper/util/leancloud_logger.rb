require 'Singleton'
require 'net/http'
require 'net/https'
require 'big_keeper/util/logger'

module BigKeeper
  class LeanCloudLogger
    include Singleton

    attr_accessor :user, :version, :start_timestamp, :end_timestamp, :command, :parameter, :is_success, :path, :need_log

    def initialize
      @need_log = "true"
    end

    def set_command(set_command)
      @command = set_command
    end

    def is_need_log
      @need_log == "true"
    end

    def start_log(global_options, args)
      @start_timestamp = Time.new.to_i
      @user = global_options['user'].to_s
      @parameter = args.join(",")
      @version = global_options['ver']
      @path = global_options['path']
      @need_log = "#{global_options[:log]}"
    end

    def end_log(is_success, is_show_log)
      @end_timestamp = Time.new.to_i
      @is_success = is_success
      @version = BigkeeperParser.version if @version == 'Version in Bigkeeper file'

      # require
      parameter = {'start_timestamp' => @start_timestamp, 'end_timestamp' =>@end_timestamp, 'user' =>@user, 'is_success' =>@is_success}

      # optional
      parameter = parameter.merge('command' => @command) unless @command == nil
      parameter = parameter.merge('version' => @version) unless @version == nil || @version == ""
      parameter = parameter.merge('parameter' => @parameter) unless @parameter == nil || @parameter == ""

      if @command
        leancloud_file = @command.split("/").first
        send_log_cloud(leancloud_file, parameter, is_show_log)
      end
    end

    def send_log_cloud(file_name, parameter, is_show_log)
      if file_name == nil
        return
      end

      if BigkeeperParser.global_configs("LeanCloudId") == nil || BigkeeperParser.global_configs("LeanCloudKey") == nil
        return
      end

      header = assemble_request

      uri = URI.parse("https://api.leancloud.cn/1.1/classes/#{file_name}")

      https = Net::HTTP.new(uri.host, 443)
      https.use_ssl = true
      https.ssl_version = :TLSv1
      https.verify_mode = OpenSSL::SSL::VERIFY_PEER
      req = Net::HTTP::Post.new(uri.path, header)
      req.body = parameter.to_json
      res = https.request(req)

      if is_show_log == true
        Logger.highlight("Send LeanCloud success, response #{res.body}")
      end
    end

    def assemble_request
      return {'Content-Type' =>'application/json', 'X-LC-Id' =>BigkeeperParser.global_configs("LeanCloudId"), 'X-LC-Key' =>BigkeeperParser.global_configs("LeanCloudKey")}
    end

    protected :send_log_cloud, :assemble_request
    end
  end
