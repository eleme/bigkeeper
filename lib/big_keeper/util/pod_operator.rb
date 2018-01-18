require 'big_keeper/util/logger'

module BigKeeper
  class PodOperator
    def self.pod_install(path, repo_update)
      Logger.highlight('Start pod install, waiting...')

      # pod install
      `pod repo update` if repo_update
      `pod install --project-directory=#{path}`

      Logger.highlight('Finish pod install.')
    end
  end
end
