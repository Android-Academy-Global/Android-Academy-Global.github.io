require "liquid"
require "achievements_list"

module Achievements

    class AchievementsCalculator

        def initialize()
            @students = Hash.new
            @homeworkReviews = Hash.new
            @homeWorks = Hash.new
            @helps = Hash.new
            @feedbacks = []
        end

        def withStudents(students)
            @students = Hash.new
            students.each { |s|
                @students[s.telegramId] = s
            }
            return self
        end

        def withStudentsHelp(helps)
            @helps = helps.group_by { |h| h.studentIdHowHelped }
            return self
        end

        def addWorkshopFeedbacks(feedbacks)
            @feedbacks = @feedbacks.concat(feedbacks)
            return self
        end

        def withHomeworks(homeWorks:, homeworkReviews:)
            @homeworkReviews = homeworkReviews.group_by { |r| r.studentId }
            @homeWorks = Hash.new
            homeWorks.each { |hw| @homeWorks[hw.id] = hw }
            return self
        end

        def calculate()
            studentsAchievements = @students.map { |id, student|
                accumulator = StudentAccomulator.new(student)
                accumulator.addAchievements(calculateHomeWorkAchievements(student))
                accumulator.addAchievements(calculateHelpingHandAchievements(student))
                accumulator.addAchievements(calculateAttendedWorkshopAchievements(student))
                accumulator
            }
            currentRatingPosition = 0
            currentScore = Float::INFINITY
            studentsRating = studentsAchievements
                .sort_by { |a| -a.currentScore }
                .map do |a| 
                    if a.currentScore < currentScore
                        currentScore = a.currentScore
                        currentRatingPosition += 1
                    end
                    StudentInRating.new(student: a.student, position: currentRatingPosition, achievements: a.achievements, totalScore: a.currentScore)
                end
            return CalculatedAchievements.new(studentsRating: studentsRating)
        end

        private def calculateHelpingHandAchievements(student)
            result = []
            studentHelps = @helps[student.telegramId]
            if (studentHelps != nil)
                studentHelps.each { |h|
                    studentWhoGotHelp = @students[h.studentIdWhoGotHelp]
                    if (studentWhoGotHelp != nil)
                        result.push(StudentsAchievement.new(
                            student: student,
                            achievement: List::HELPING_HAND,
                            achievementReason: "Comment from #{studentWhoGotHelp.name}: #{h.comment}"
                        ))
                    end
                }    
            end
            return result
        end

        private def calculateAttendedWorkshopAchievements(student)
            studentFeedbacks = @feedbacks.select {|a| a.studentId == student.telegramId}.uniq {|a| a.workshopId}
            result = []
            studentFeedbacks.each { |f|
                workshop = @homeWorks[f.workshopId]
                if (workshop != nil)
                    result.push(
                        StudentsAchievement.new(
                            student: student,
                            achievement: List::ATTENDED_WORKSHOP,
                            achievementReason: "For beeing a part of #{workshop.name}"
                    ))
                    if (f.toImprove != nil && f.toImprove != "")
                        result.push(
                            StudentsAchievement.new(
                                student: student,
                                achievement: List::CRITIC,
                                achievementReason: "For helping us improve #{workshop.name}"
                        ))
                    end
                end
            }
            
            return result
        end

        private def calculateHomeWorkAchievements(student)
            completedHomeworks = @homeworkReviews[student.telegramId]
            if completedHomeworks == nil
                return []
            end
            result = []
            nextHomeworkAchievement = List::HOME_WORK_COMPLETED_1
            lastCompletedHomework = -99
            completedHomeworks
                .sort_by { |homeWorkReview| @homeWorks[homeWorkReview.homeWorkId].orderNumber }
                .each { |homeWorkReview|
                    homeWork = @homeWorks[homeWorkReview.homeWorkId]
                    if (homeWork.orderNumber - 1 != lastCompletedHomework)
                        nextHomeworkAchievement = List::HOME_WORK_COMPLETED_1
                    end
                    if homeWork.dueDate >= homeWorkReview.homeworkCompletedDate
                        result.push(
                            StudentsAchievement.new(
                                student: student,
                                achievement: nextHomeworkAchievement,
                                achievementReason: "For completing homework from #{homeWork.name} workshop"
                            )
                        )
                        nextHomeworkAchievement = nextHomeworkCompleted(nextHomeworkAchievement)
                    else
                        nextHomeworkAchievement = List::HOME_WORK_COMPLETED_1
                    end
                    lastCompletedHomework = homeWork.orderNumber
                }
            return result
        end
    end

    class StudentAccomulator
        def initialize(student)
            @student = student
            @achievements = []
            @currentScore = 0
        end

        def addAchievements(achievements)
            @achievements.concat(achievements)
            @currentScore = achievements.inject(@currentScore) { |acc, a| acc + a.achievement.value }
        end

        def student
            @student
        end

        def achievements
            @achievements
        end

        def currentScore
            @currentScore
        end
    end

    class WorkshopFeedback
        attr_reader :workshopId, :studentId, :timestamp, :toImprove
        def initialize(workshopId:, studentId:, timestamp:, toImprove:)
            @workshopId = workshopId
            @studentId = studentId
            @timestamp = timestamp
            @toImprove = toImprove
        end
    end

    class CalculatedAchievements
        attr_reader :studentsRating
        def initialize(studentsRating:)
            @studentsRating = studentsRating
        end
    end

    class Student < Liquid::Drop
        attr_reader :telegramId, :name
        def initialize(telegramId:, name:)
            @telegramId = telegramId
            @name = name
        end
    end

    class StudentsAchievement < Liquid::Drop
        attr_reader :student, :achievement, :achievementReason
        
        def initialize(student:, achievement:, achievementReason:)
            @student = student
            @achievement = achievement
            @achievementReason = achievementReason
        end
    end

    class StudentInRating < Liquid::Drop
        attr_reader :student, :position, :achievements, :totalScore
        def initialize(student:, position:, achievements:, totalScore:)
            @student = student
            @position = position
            @achievements = achievements
            @totalScore = totalScore
        end
    end

    class HomeWork < Liquid::Drop
        attr_reader :id, :name, :dueDate, :orderNumber
        def initialize(id:, name:, dueDate:, orderNumber:)
            @id = id
            @name = name
            @dueDate = dueDate
            @orderNumber = orderNumber
        end
    end

    class HomeWorkReview < Liquid::Drop
        attr_reader :homeWorkId, :mentorId, :studentId, :homeworkCompletedDate
        def initialize(homeWorkId:, mentorId:, studentId:, homeworkCompletedDate:)
            @homeWorkId = homeWorkId
            @mentorId = mentorId
            @studentId = studentId
            @homeworkCompletedDate = homeworkCompletedDate
        end
    end

    class StudentHelp < Liquid::Drop
        attr_reader :studentIdHowHelped, :studentIdWhoGotHelp, :comment
        def initialize(studentIdHowHelped:, studentIdWhoGotHelp:, comment:)
            @studentIdHowHelped = studentIdHowHelped
            @studentIdWhoGotHelp = studentIdWhoGotHelp
            @comment = comment
        end
    end

    class TelegramName < Liquid::Drop
        
        def initialize(name)
            @name = name
            @normalizedName = normalizeName(name)
        end
    
        def ==(other)
            if (other.is_a? String)
                other = TelegramName.new(other)
            end
            return other.normalizedName == @normalizedName
        end

        def eql?(other)
            return self == other
        end

        def hash
            @normalizedName.hash
        end

        def to_str
            @name
        end

        def to_s
            @name
        end

        protected
            def normalizedName
                @normalizedName
            end

        private
            def normalizeName(name)
                result = name.strip() || name
                result.sub! '@', ''
                result.downcase!
                return result
            end
    end

end