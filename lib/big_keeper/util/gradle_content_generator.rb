module BigKeeper
  class GradleConentGenerator
    def self.generate_bigkeeper_settings_gradle_content(big_settings_file)
"
//bigkeeper config start
Properties properties = new Properties()
properties.load(new File('local.properties').newDataInputStream())
if (\'true\' == properties.getProperty(\'ENABLE_BIGKEEPER_LOCAL\')) {
\tapply from: \'#{big_settings_file}\'
}
//bigkeeper config end"
    end

    def self.generate_bigkeeper_build_gradle_content(big_build_file)
"
//bigkeeper config start
Properties properties = new Properties()
properties.load(project.rootProject.file('local.properties').newDataInputStream())
if (\'true\' != properties.getProperty(\'ENABLE_BIGKEEPER_LOCAL\')) {
\tapply from: \'#{big_build_file}\'
}
//bigkeeper config end
"
    end
  end
end
