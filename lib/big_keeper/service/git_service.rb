
module BigKeeper
  # Operator for got
  class GitService
    def verify_rebase(name, path, branch_name)
      has_confict = true
      IO.popen("cd #{path}; git rebase #{branch_name}") do |io|
        io.each do |line|
          raise "Merge conflict in #{name}" if line.include? 'Merge conflict in '
        end
      end

      if has
    end
  end
end
