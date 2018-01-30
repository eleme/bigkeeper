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
  end
end
