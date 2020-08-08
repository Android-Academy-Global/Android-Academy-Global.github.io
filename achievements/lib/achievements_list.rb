module Achievements

    class Achievement < Liquid::Drop
        attr_reader :id, :name, :description, :value
        def initialize(id:, name:, description:, value:)
            @id = id
            @name = name
            @description = description
            @value = value
        end
    end

    module List
        HELPING_HAND = Achievement.new(id: "helping_hand", value: 100, name: "Helping Hand", description: "Student helped some other student")
        HOME_WORK_COMPLETED_1 = Achievement.new(id: "homework_completed_1", value: 100, name: "Completed homework", description: "Studend completed homework")
        HOME_WORK_COMPLETED_2 = Achievement.new(id: "homework_completed_2", value: 200, name: "2 Homeworks in the row", description: "Studend completed 2 homeworks in a row in time")
        HOME_WORK_COMPLETED_3 = Achievement.new(id: "homework_completed_3", value: 300, name: "3 Homeworks in the row", description: "Studend completed 3 homeworks in a row in time")
        HOME_WORK_COMPLETED_4 = Achievement.new(id: "homework_completed_4", value: 500, name: "4 Homeworks in the row", description: "Studend completed 4 homeworks in a row in time")
        HOME_WORK_COMPLETED_5 = Achievement.new(id: "homework_completed_5", value: 700, name: "5 Homeworks in the row", description: "Studend completed 5 homeworks in a row in time")
    end

end