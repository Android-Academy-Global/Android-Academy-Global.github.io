module Achievements

    class Achievement < Liquid::Drop
        attr_reader :id, :name, :description, :value
        def initialize(id:, name:, description:, value:)
            @id = id
            @name = name
            @description = description
            @reason = reason
        end
    end

    module List
        HELPING_HAND = Achievement.new(id: "helping_hand", name: "Helping Hand", description: "Student helped some other student")
        HOME_WORK_COMPLETED = Achievement.new(id: "homework_completed", name: "Completed homework", description: "Studend completed homework")
        HOME_WORK_COMPLETED_2 = Achievement.new(id: "homework_completed", name: "Completed homework", description: "Studend completed homework")
        HOME_WORK_COMPLETED_3 = Achievement.new(id: "homework_completed", name: "Completed homework", description: "Studend completed homework")
        HOME_WORK_COMPLETED_4 = Achievement.new(id: "homework_completed", name: "Completed homework", description: "Studend completed homework")
        HOME_WORK_COMPLETED_5 = Achievement.new(id: "homework_completed", name: "Completed homework", description: "Studend completed homework")
    end

end