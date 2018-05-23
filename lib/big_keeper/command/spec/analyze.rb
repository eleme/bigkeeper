require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/dependency/dep_type'
require 'big_keeper/util/logger'
require 'big_keeper/model/library_model'

module BigKeeper
  def self.spec_analyze(path,is_all,find_module_names)
    is_default = !is_all&&find_module_names.size==0
    if is_all && find_module_names.size>0
      Logger.error("parameter conflict: [--all] | [module_names]")
      return
    end
    puts "start spec analyze..."
    puts Time.now.to_s

    # Parse Bigkeeper file
    # BigkeeperParser.parse("#{path}/Bigkeeper")
    # module_names = BigkeeperParser.module_names

    # find modules
    puts "get all modules..."
    module_names = []
    pod_path = path+"/Pods/"
    dir = Dir.open(pod_path)
    dir.each do |dir_name|
      if !dir_name.include?(".") && dir_name != "Headers" && dir_name != "Local Podspecs" && dir_name != "Target Support Files"
        module_names[module_names.size]=dir_name
      end
    end

    is_legal = true
    for input_moudle_name in find_module_names do
      if !module_names.include?(input_moudle_name)
        is_legal = false
        Logger.error("["+input_moudle_name+"] not exist.")
      end
    end
    if !is_legal
      return
    end

    # setup modules
    module_list = []
    module_keyword_map = Hash.new
    file_count = 0
    for module_name in module_names do
      library = LibraryModel.new(module_name)
      library.get_all_public_file(path)
      module_list[module_list.size]=library
      module_keyword_map[module_name]=library.keyword_list
      if is_all || find_module_names.include?(library.name)
        file_count = file_count + library.file_list.size
      end
    end
    # analyze modules spec

    puts "analyze modules "+Time.now.to_s
    file_index = 0
    for library in module_list do
      if is_all || find_module_names.include?(library.name)
        puts "analyzing "+library.name
        file_index = file_index + library.file_list.size
        library.spec_dependece_library(module_keyword_map.clone)#(Hash.new(module_keyword_map)).to_hash)
        progress = (file_index*100.0)/file_count
        progress = format("%.02f", progress).to_f
        puts "progress >>>> "+String(progress)+"% ["+library.name+" done] "
      end
    end
    puts "analyze complete "+Time.now.to_s

    # log spec info
    for library in module_list do
      if is_all || find_module_names.include?(library.name)
        Logger.highlight("\n-"+library.name+":")
        for spec_library in library.spec_library do
          puts " -"+spec_library
        end
      end
    end

    # save cache to file
    if is_all

    end

  end

end
