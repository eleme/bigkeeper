module BigKeeper
  module OperateType
    START = 1
    UPDATE = 2
    SWITCH = 3
    FINISH = 4
    PUBLISH = 5
    RELEASE = 6

    def self.name(type)
      if START == type
        "start"
      elsif UPDATE == type
        "update"
      elsif SWITCH == type
        "switch"
      else
        name
      end
    end
  end

  module ModuleOperateType
    ADD = 1
    DELETE = 2
    FINISH = 3
    PUBLISH = 4
    RELEASE = 5
    RELEASE_START = 6
  end
end
