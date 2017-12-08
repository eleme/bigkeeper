require 'big_keeper/util/logger'

module BigKeeper
  class PodOperator
    def self.pod_install(path)
      Logger.highlight('Start pod install, waiting...')

      # pod install
      `pod install --project-directory=#{path}`

      Logger.highlight('Finish pod install.')
    end
  end
end
