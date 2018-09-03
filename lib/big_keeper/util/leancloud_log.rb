require 'Singleton'
require 'net/http'
require 'net/https'

module BigKeeper
  class LeanCloudLog
    include Singleton

	  attr_accessor :user, :version, :startTimestamp, :endTimestamp, :command, :parameter, :isSuccess, :path

    def set_command(set_command)
      @command = set_command
    end

    def start_log(global_options, args)
      @startTimestamp = Time.new.to_i
      @user = global_options['user'].to_s
      @parameter = args.join(",")
      @version = global_options['ver']
      @path = global_options['path']
    end

    def end_log(isSuccess)
      @endTimestamp = Time.new.to_i
      @isSuccess = isSuccess
      @version = BigkeeperParser.version if @version == 'Version in Bigkeeper file'

      # require
      parameter = {'startTimestamp' => @startTimestamp, 'endTimestamp' =>@endTimestamp, 'user' =>@user, 'isSuccess' =>@isSuccess}

      # optional
      parameter = parameter.merge('command' => @command) unless @command == nil
      parameter = parameter.merge('version' => @version) unless @version == nil || @version == ""
      parameter = parameter.merge('parameter' => @parameter) unless @parameter == nil || @parameter == ""

      leancloud_file = @command.split("/").first

      send_log_cloud(leancloud_file, parameter)
    end

    def send_log_cloud(file_name, parameter)
      if file_name == nil
        return
      end

      BigkeeperParser.parse("#{@path}/Bigkeeper")
      if BigkeeperParser.global_config("LeanCloudId") == nil || BigkeeperParser.global_config("LeanCloudKey") == nil
        return
      end

      header = assemble_request

      uri = URI.parse("hhttps://api.leancloud.cn/1.1/classes/#{file_name}")

      https = Net::HTTP.new(uri.host, 443)
      https.use_ssl = true
      https.ssl_version = :TLSv1
      https.verify_mode = OpenSSL::SSL::VERIFY_PEER
      req = Net::HTTP::Post.new(uri.path, header)
      req.body = parameter.to_json
      res = https.request(req)

      puts "Response #{res.code} #{res.message}: #{res.body}"
    end

    def assemble_request
      return {'Content-Type' =>'application/json', 'X-LC-Id' =>BigkeeperParser.global_config("LeanCloudId"), 'X-LC-Key' =>BigkeeperParser.global_config("LeanCloudKey")}
    end

    protected :send_log_cloud, :assemble_request
  end

end
