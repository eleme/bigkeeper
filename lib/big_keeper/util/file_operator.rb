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

  class << FileOperator
    def find_all_header_file(path)
      return Dir.glob("#{path}/**/*.h")
    end
    def find_all_code_file(path)
      header_file_list = Dir.glob("#{path}/**/*.[h]")
      m_file_list = Dir.glob("#{path}/**/*.[m]")
      return header_file_list+m_file_list
    end
  end

end
