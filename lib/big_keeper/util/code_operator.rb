module BigKeeper

  class OCCodeOperator
  end

  class << OCCodeOperator

    def in_note_code(line_hash)
      line = line_hash["line"]
      in_note = line_hash["in_note"]
      line = line.strip
      if in_note
        line_hash["line"]=""
        if (line.include?("*/"))
          line_hash["in_note"] = false
        end
        return
      end
      if line[0,2] == "//" || line[0,7] == "#pragma"
        line_hash["line"]=""
        return
      end
      if line.include?("/*")
        line_hash["in_note"] = true
        before_line = line[line.index("/*")+1...line.size]
        if before_line.include?("*/")
          line_hash["in_note"] = false
        end
        line_hash["line"] = line[0,line.index("/*")]
        return
      end

    end

  end

end
