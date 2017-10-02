require 'big_stash/stash_operator'

module BigKeeper
  class InfoPlistOperator
    def change_version_build(path, version)
      p `Version will change to #{{version}}`
    end
  end
end
