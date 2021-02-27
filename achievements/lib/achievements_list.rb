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

    HOME_WORK_GENERIC_DESCRIPTION = "Homework is the most important part of your journey in Android developmenet. Here you can apply all knowledge that you got on the resent lectures, find gaps and even learn something new."

    module List
        ATTENDED_WORKSHOP = Achievement.new(id: "attended_workshop", value: 100, name: "Attended workshop", description: "Student attended workshop")
        HELPING_HAND = Achievement.new(id: "helping_hand", value: 40, name: "Helping Hand", description: "Student helped some other student")
        HOME_WORK_COMPLETED_1 = Achievement.new(id: "homework_completed_1", value: 100, name: "Completed homework", description: "#{HOME_WORK_GENERIC_DESCRIPTION} Every time you send homework to your mentor before the deadline you get this achievement.")
        HOME_WORK_COMPLETED_2 = Achievement.new(id: "homework_completed_2", value: 200, name: "2 Homeworks in the row", description: "#{HOME_WORK_GENERIC_DESCRIPTION} To get this achievement complete two homeworks in the row before the dead line.")
        HOME_WORK_COMPLETED_3 = Achievement.new(id: "homework_completed_3", value: 300, name: "3 Homeworks in the row", description: "#{HOME_WORK_GENERIC_DESCRIPTION} To get this achievement complete three homeworks in the row before the dead line.")
        HOME_WORK_COMPLETED_4 = Achievement.new(id: "homework_completed_4", value: 500, name: "4 Homeworks in the row", description: "#{HOME_WORK_GENERIC_DESCRIPTION} To get this achievement complete four homeworks in the row before the dead line.")
        HOME_WORK_COMPLETED_5 = Achievement.new(id: "homework_completed_5", value: 700, name: "5 Homeworks in the row", description: "#{HOME_WORK_GENERIC_DESCRIPTION} To get this achievement complete five homeworks in the row before the dead line.")
        CRITIC = Achievement.new(id: "critic", value: 20, name: "Critic", description: "For helping us find things to improve.")
        BEST_QUESTION = Achievement.new(id: "best_question", value: 40, name: "The best question", description: "For asking very good questions.")
        LATE_HOMEWORK = Achievement.new(id: "late_homework", value: 40, name: "Late Homework", description: "It's great to get things done even after due date. Great job!")
        EXCELLENT_HOMEWORK = Achievement.new(id: "excellent_homework", value: 30, name: "Excellent Homework", description: "Mentor put the highest mark for your homework. Well done!")

        HACKATHON_FIRST_PLACE = Achievement.new(id: "hackathon_first_place", value: 1000, name: "The hackathon winner", description: "Implemented the best app on the Hackathon")
        HACKATHON_SECOND_PLACE = Achievement.new(id: "hackathon_second_place", value: 800, name: "Second place on hackathon", description: "Took the second place on the hackathon")
        HACKATHON_THIRD_PLACE = Achievement.new(id: "hackathon_third_place", value: 600, name: "Third place on hackathon", description: "Took the third place on the hackathon")
        HACKATHON_PARTICIPANT = Achievement.new(id: "hackathon_participant", value: 400, name: "The hackathon veteran", description: "Got throught the hackathon")
        HACKATHON_BEST_IDEA = Achievement.new(id: "hackathon_best_idea", value: 700, name: "Best idea on the Hackathon", description: "Implemented project with the best idea on the hackathon")
        HACKATHON_BEST_IMPLEMENTATION = Achievement.new(id: "hackathon_best_implementation", value: 700, name: "Best implementation on the Hackathon", description: "Implemented project better then anyone else")

        ALL_ACHIEVEMENTS = [
            HELPING_HAND,
            HOME_WORK_COMPLETED_1,
            HOME_WORK_COMPLETED_2,
            HOME_WORK_COMPLETED_3,
            HOME_WORK_COMPLETED_4,
            HOME_WORK_COMPLETED_5,
            ATTENDED_WORKSHOP,
            CRITIC,
            BEST_QUESTION,
            LATE_HOMEWORK,
            EXCELLENT_HOMEWORK,
            HACKATHON_FIRST_PLACE,
            HACKATHON_SECOND_PLACE,
            HACKATHON_THIRD_PLACE,
            HACKATHON_PARTICIPANT,
            HACKATHON_BEST_IDEA,
            HACKATHON_BEST_IMPLEMENTATION
        ]
    end

    def nextHomeworkCompleted(achievement)
        return case achievement.id
        when List::HOME_WORK_COMPLETED_1.id
            List::HOME_WORK_COMPLETED_2
        when List::HOME_WORK_COMPLETED_2.id
            List::HOME_WORK_COMPLETED_3
        when List::HOME_WORK_COMPLETED_3.id
            List::HOME_WORK_COMPLETED_4
        when List::HOME_WORK_COMPLETED_4.id
            List::HOME_WORK_COMPLETED_5
        when List::HOME_WORK_COMPLETED_5.id
            List::HOME_WORK_COMPLETED_1
        else
            raise "wrong homework achievement #{achievement.id}"
        end
    end

end