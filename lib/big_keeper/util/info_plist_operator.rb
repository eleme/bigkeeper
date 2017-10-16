#!/usr/bin/ruby
require 'plist' # gem install plist
require 'big_stash/stash_operator'
require 'pathname'

module BigKeeper
  # Operator for Info.plist
  class InfoPlistOperator
    def change_version_build(path, version)
      if find_infoPlist_filePath(path) == ''
        raise %(Not find be Info.plist at #{path})
      end
      info_plist_path = find_infoPlist_filePath(path)
      result = Plist.parse_xml(info_plist_path)
      result['CFBundleShortVersionString'] = version.to_s
      result['CFBundleVersion'] = getBuildVersion(version, result['CFBundleShortVersionString'], result['CFBundleVersion'])
      Plist::Emit.save_plist(result, info_plist_path)
      puts %Q('Version has changed to #{version}')
    end

    # Find Info.plist file path
    # @return [String] pathName of info.plist
    def find_infoPlist_filePath(path)
      paths = Pathname.new(path).children.select { |pn| pn.extname == '.xcodeproj' }
      xcodePath = paths[0].to_s.split('/')[-1]
      projectName = xcodePath.split('.')[0]
      projectPath = ''
      Pathname.new("#{path}/#{projectName}").children.select { |pn|
        if pn.to_s == "#{path}/#{projectName}/Info.plist"
          projectPath = "#{path}/#{projectName}/Info.plist"
        end
      }
      projectPath
    end

    private
    def getBuildVersion(build_string, old_build_string, old_build_version)
      if build_string == old_build_string
        return old_build_version.to_i + 1
      else
        version_arr = build_string.split('.')
        return version_arr[0].to_i * 1000 + version_arr[1].to_i * 100 + version_arr[2].to_i * 10
      end
    end
  end
end
