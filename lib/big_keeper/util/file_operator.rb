module BigKeeper
  # Operator for got
  class FileOperator
    def self.definitely_exists? path
      folder = File.dirname path
      filename = File.basename path
      # Unlike Ruby IO, ls, and find -f, this technique will fail to locate the file if the case is wrong:
      not %x( find "#{folder}" -name "#{filename}" ).empty?
    end

    def find_all(path, name)
      Dir.glob("#{path}/*/#{name}")
    end

    def current_username
      current_name = `whoami`
      current_name.chomp
    end
    
  end
end
