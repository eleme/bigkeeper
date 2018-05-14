module BigKeeper
  # Operator for got
  class VerifyOperator
    def self.already_in_process?
      already_in_process = false
      Open3.popen3('ps aux | grep \<big\> -c') do |stdin , stdout , stderr, wait_thr|
        while line = stdout.gets
          if line.rstrip.to_i > 2
            already_in_process = true
            break
          end
        end
      end
      already_in_process
    end
  end
end
