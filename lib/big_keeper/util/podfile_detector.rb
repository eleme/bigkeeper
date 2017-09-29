require 'tempfile'
require 'fileutils'
require '../util/param_parser'
require '../util/podfile_operator'
require '../model/podfile_type'



params = BigKeeper::ParamParser.new.detect_podfile_unlock_items
main_path = File.expand_path(params[:main_path])

class PodfileDetector
  $unlock_pod_list = []
  def get_unlock_pod_list(main_path)
    podfile_lock_lines = File.readlines("#{main_path}/Podfile.lock")
    podfile_lines = File.readlines("#{main_path}/Podfile")
     p 'Analyzing Podfile...' unless podfile_lines.size.zero?
      podfile_lines.select do |sentence|
        if sentence =~(/:tag => \'[0-9]\.[0-9]\.[0-9]+\'/)
          get_pod_name(sentence)
        end
      end
      p $unlock_pod_list
  end

  def get_pod_name(sentence)
    match_data = /\'\w*\'/.match(sentence)
    pod_name = match_data.to_a[0].gsub(/\'/,'')
    puts pod_name
    $unlock_pod_list << pod_name
  end

  # private get_pod_name
end

p params
p main_path
PodfileDetector.new.get_unlock_pod_list(main_path)
