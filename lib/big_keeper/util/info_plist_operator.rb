#!/usr/bin/ruby
require 'rexml/document'
include REXML
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

      p `Version will change to #{{version}}`
      // # TODO: --
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
  end
end
