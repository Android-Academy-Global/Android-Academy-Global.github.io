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
            @bestQuestions = Hash.new
        end

        def withStudents(students)
            @students = Hash.new
            students.each { |s|
                @students[s.telegramId] = s
            }
            return self
        end

        def withBestQuestions(bestQuestions)
            @bestQuestions = bestQuestions.group_by { |q| q.studentId }
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
                accumulator.addAchievements(calculateBestQuestionsAchievement(student))
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
                            achievementReason: "Comment from <a href=\"/students/#{studentWhoGotHelp.telegramId}/\">#{studentWhoGotHelp.name}</a>: #{h.comment}"
                        ))
                    end
                }
            end
            return result
        end

        private def calculateAttendedWorkshopAchievements(student)
          studentFeedbacks = @feedbacks.select { |a| a.studentId == student.telegramId }.group_by { |f| f.workshopId }

          studentFeedbacks.each_with_object([]) do |(key, value), result|
            workshop = @homeWorks[key]

            next unless workshop

            feedback = value.sort_by { |f| f.toImprove || '' }.last

            result.push(
              StudentsAchievement.new(
                student: student,
                achievement: List::ATTENDED_WORKSHOP,
                achievementReason: "For beeing a part of #{workshop.name}"
              )
            )

            next if feedback.toImprove == nil || feedback.toImprove == ""

            result.push(
              StudentsAchievement.new(
                student: student,
                achievement: List::CRITIC,
                achievementReason: "For helping us improve #{workshop.name}"
              )
            )
          end
        end

        private def calculateHomeWorkAchievements(student)
            completedHomeworks = @homeworkReviews[student.telegramId]
            if completedHomeworks == nil
                return []
            end
            completedHomeworks = completedHomeworks.uniq { |hw| hw.homeWorkId }
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
                    achievementReason = "For completing homework from #{homeWork.name} workshop"
                    if homeWork.dueDate >= homeWorkReview.homeworkCompletedDate
                        result.push(
                            StudentsAchievement.new(
                                student: student,
                                achievement: nextHomeworkAchievement,
                                achievementReason: achievementReason
                            )
                        )
                        nextHomeworkAchievement = nextHomeworkCompleted(nextHomeworkAchievement)
                    else
                        result.push(
                            StudentsAchievement.new(
                                student: student,
                                achievement: List::LATE_HOMEWORK,
                                achievementReason: achievementReason
                            )
                        )
                        nextHomeworkAchievement = List::HOME_WORK_COMPLETED_1
                    end
                    if (homeWorkReview.mark >= 9)
                        result.push(
                            StudentsAchievement.new(
                                student: student,
                                achievement: List::EXCELLENT_HOMEWORK,
                                achievementReason: "For excellence in homework from #{homeWork.name} workshop"
                            )
                        )
                    end
                    lastCompletedHomework = homeWork.orderNumber
                }
            return result
        end

        private def calculateBestQuestionsAchievement(student)
            studentsBestQuestions = @bestQuestions[student.telegramId]
            if (studentsBestQuestions == nil)
                return []
            end
            result = []
            studentsBestQuestions.each { |q|
                workshop = @homeWorks[q.workshopId]
                if (workshop != nil)
                    veryGoodQuestionText = "very good question"
                    if (q.linkToQuestion != nil && q.linkToQuestion != '')
                        veryGoodQuestionText = "<a href=\"#{q.linkToQuestion}\">#{veryGoodQuestionText}</a>"
                    end
                    result.push(
                        StudentsAchievement.new(
                            student: student,
                            achievement: List::BEST_QUESTION,
                            achievementReason: "For asking #{veryGoodQuestionText} at #{workshop.name} workshop."
                        )
                    )
                end
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
        attr_reader :homeWorkId, :mentorId, :studentId, :homeworkCompletedDate, :mark
        def initialize(homeWorkId:, mentorId:, studentId:, homeworkCompletedDate:, mark:)
            @homeWorkId = homeWorkId
            @mentorId = mentorId
            @studentId = studentId
            @homeworkCompletedDate = homeworkCompletedDate
            @mark = mark
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

    class BestQuestion < Liquid::Drop
        attr_reader :studentId, :workshopId, :linkToQuestion
        def initialize(studentId:, workshopId:, linkToQuestion:)
            @studentId = studentId
            @workshopId = workshopId
            @linkToQuestion = linkToQuestion
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
