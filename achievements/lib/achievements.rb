require "liquid"
require "achievements_list"

module Achievements

    class AchievementsCalculator
        def self.calculateRating(students)
            # achievementsHashTable = {}
            # for achievement in achievements
            # achievementsHashTable[achievement["id"]] = achievement
            # end

            # return students
            # .map { |student|
            #     achievementsOfTheStudent = student["achievements"].map { |id| achievementsHashTable[id] }
            #     StudentInRating.new(student, achievementsOfTheStudent)
            # }
            # .sort_by {|rating| rating.score * -1}
            return students
                .map { |student|
                    StudentInRating.new(student)
                }
        end
    end

    class Student < Liquid::Drop
        attr_reader :telegramId, :name
        def initialize(telegramId:, name:)
            @telegramId = telegramId
            @name = name
        end
    end

    class StudentInRating < Liquid::Drop
        def initialize(student)
            @student = student
        end

        def student
            @student
        end
    end

    class HomeWork < Liquid::Drop
        attr_reader :id, :dueDate
        def initialize(id:, dueDate:)
            @id = id
            @dueDate = dueDate
        end
    end

    class HomeWorkReview < Liquid::Drop
        attr_reader :homeWorkId, :mentorId, :studentId, :reviewDate
        def initialize(homeWorkId:, mentorId:, studentId:, reviewDate:)
            @homeWorkId = homeWorkId
            @mentorId = mentorId
            @studentId = studentId
            @reviewDate = reviewDate
        end
    end

end