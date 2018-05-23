require 'big_keeper/util/file_operator'
require 'big_keeper/util/code_operator'


module BigKeeper
  class LibraryModel
    attr_accessor :name, :file_list, :header_file_list, :keyword_list, :spec_library
    def initialize(name)
      @name = name
      @file_list = []
      @header_file_list = []
      @spec_library = []
      @keyword_list = []
    end

    def get_all_public_file(path)
      all_header = FileOperator.find_all_header_file("#{path}/Pods/#{@name}")
      for file_path in all_header do
        @header_file_list[@header_file_list.size] = file_path
        file_name = File.basename(file_path)
        @keyword_list[@keyword_list.size] = file_name
        in_note = false
        File.foreach(file_path) { |line|
          hash = Hash.new
          hash["in_note"]=in_note
          hash["line"]=line
          OCCodeOperator.in_note_code(hash)
          in_note = hash["in_note"]
          line = hash["line"]
          if line.empty?
            next
          end
          if line.include?("@interface ")
            line[0,line.index("@interface ")+11]=""
            column = line.split(/:/)
            if column.size > 1
              class_name = column[0]
              if class_name.include?("<")
                class_name = class_name[0, class_name.index("<")]
              end
              class_name = class_name.strip
              if (@keyword_list.include?(class_name+".h"))
                @keyword_list.delete(class_name+".h")
              end
              @keyword_list[@keyword_list.size] = class_name
            end
          end
        }
      end
      # if @name == ""
      #   puts @keyword_list
      # end
      @file_list = FileOperator.find_all_code_file("#{path}/Pods/#{@name}")
    end

    def spec_dependece_library(library_keywords_hash)
      if library_keywords_hash.include?(@name)
        library_keywords_hash.delete(@name)
      end

      for file_path in @file_list do
        # note for coding
        in_note = false
        File.foreach(file_path) { |line|
          hash = Hash.new
          hash["in_note"]=in_note
          hash["line"]=line
          OCCodeOperator.in_note_code(hash)
          in_note = hash["in_note"]
          line = hash["line"]
          if line.empty?
            next
          end
          library_keywords_hash.each {|library_name, keyword_list|
            is_dependence = false
            tip = ""
            for keyword in keyword_list do
              if line.include?(keyword)
                last_char = '.'
                last_index = line.index(keyword)-1
                if last_index >= 0
                  last_char = line[last_index]
                end
                next_char = '.'
                next_index = line.index(keyword)+keyword.size
                if next_index < line.size
                  next_char = line[next_index]
                end
                if !(((next_char<='z'&&next_char>='a')||(next_char<='Z'&&next_char>='A')||(next_char<='9'&&next_char>='0')||next_char=='_')||((last_char<='z'&&last_char>='a')||(last_char<='Z'&&last_char>='A')||(last_char<='9'&&last_char>='0')||last_char=='_'))
                  if keyword.include?(".h") && line.include?("import") && line.include?("/"+keyword+">")
                    dependence_library_name = line[line.index("<")+1...line.index("/"+keyword+">")]
                    if dependence_library_name == library_name
                      tip = " [file]:"+File.basename(file_path)+" [line]: "+line.strip+" [keyword]: "+keyword
                      is_dependence = true
                      break
                    end
                  else
                    tip = " [file]:"+File.basename(file_path)+" [line]: "+line.strip+" [keyword]: "+keyword
                    is_dependence = true
                    break
                  end
                end
              end
            end
            if is_dependence
              @spec_library[@spec_library.size] = library_name+tip
              library_keywords_hash.delete(library_name)
            end
          }

        }
      end
    end

  end
end
