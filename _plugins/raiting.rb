require "achievements"

include Achievements

module Rating

  class RatingDataGenerator < Jekyll::Generator
    def generate(site)
      ratingTemplate = site.pages.detect {|page| page.path == "rating/index.html" }
      ratingCalculator = AchievementsCalculator.new()

      students = site.data["students"].map { |student|
        Student.new(telegramId: TelegramName.new(student["telegramId"]), name: student["name"])
      }
      ratingCalculator.withStudents(students)

      orderNumber = -1
      homeWorks = site.data["homeworks"].map { |homework|
        orderNumber = orderNumber + 1
        HomeWork.new(id: homework["id"], name: homework["name"], dueDate: parseDate(homework["dueDate"]), orderNumber: orderNumber)
      }
      homeWorksReviews = site.data["homework-reviews"].map { |review|
        HomeWorkReview.new(
          homeWorkId: review["homeworkId"],
          mentorId: TelegramName.new(review["mentorId"]),
          studentId: TelegramName.new(review["studentId"]),
          homeworkCompletedDate: parseDate(review["homeworkCompleted"]),
          mark: Integer(review["mark"])
        )
      }
      ratingCalculator.withHomeworks(homeWorks: homeWorks, homeworkReviews: homeWorksReviews)

      studentsHelps = site.data["students-helps"].map { |help|
        StudentHelp.new(studentIdHowHelped: TelegramName.new(help["to"]), studentIdWhoGotHelp: TelegramName.new(help["from"]), comment: help["comment"])
      }
      ratingCalculator.withStudentsHelp(studentsHelps)

      site.data["homeworks"].each { |homework|
          attendeesFileName = homework["id"] + "-attendees"
          if site.data[attendeesFileName] != nil
            attendees = site.data[attendeesFileName].map { |a|
              WorkshopFeedback.new(workshopId: homework["id"], studentId: TelegramName.new(a["telegramId"]), timestamp: parseTimeStamp(a["Timestamp"]), toImprove: a["toImprove"])
            }
            ratingCalculator.addWorkshopFeedbacks(attendees)
          end
      }

      bestQuestions = site.data["best-questions"].map {|q|
        BestQuestion.new(workshopId: q["workshopId"], studentId: TelegramName.new(q["studentId"]), linkToQuestion: q["linkToQuestion"])
      }
      ratingCalculator.withBestQuestions(bestQuestions)

      hackathonParticipants = site.data["hackathon-participants"].map { |p|
        HackathonParticipant.new(studentId: TelegramName.new(p["studentId"]), teamName: p["team"])
      }
      ratingCalculator.withHackthonParticipants(hackathonParticipants)

      manualAchiements = site.data["hackathon-winners"].map { |w|
        ManualAchievement.new(studentId: TelegramName.new(w["studentId"]), achievementId:w["achievementId"], reason:w["reason"])
      }
      ratingCalculator.withManualAchievements(manualAchiements)

      rating = ratingCalculator.calculate().studentsRating
      ratingTemplate.data["rating"] = rating

      rating.each do |studentInRating|
        site.pages << StudentPage.new(site, studentInRating)
      end

      List::ALL_ACHIEVEMENTS.each do |achievement|
        site.pages << AchievementPage.new(site, achievement)
      end
    end

    def parseDate(date)
      return Date.strptime(date, "%Y-%m-%d")
    end

    def parseTimeStamp(timeStamp)
      return Date.strptime(timeStamp, "%m/%d/%Y %k:%M:%S")
    end
  end


  class StudentPage < Jekyll::Page
    def initialize(site, studentInRating)
      @site = site
      @base = site.source
      @dir = File.join('students', studentInRating.student.telegramId)
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(@base, '_layouts'), "student.html")
      self.data["studentInRating"] = studentInRating
      self.data["title"] = studentInRating.student.name
    end
  end

  class AchievementPage < Jekyll::Page
    def initialize(site, achievement)
      @site = site
      @base = site.source
      @dir = File.join('achievements', achievement.id)
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(@base, '_layouts'), "achievement.html")
      self.data["achievement"] = achievement
    end
  end

end