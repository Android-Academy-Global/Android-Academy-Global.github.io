require "achievements"

include Achievements

module Rating

  class RatingDataGenerator < Jekyll::Generator
    def generate(site)
      ratingTemplate = site.pages.detect {|page| page.name == 'rating.html'}
      ratingCalculator = AchievementsCalculator.new()

      students = site.data["students"].map { |student|
        Student.new(telegramId: student["telegramId"], name: student["name"])
      }
      ratingCalculator.withStudents(students)

      orderNumber = -1
      #TODO: order by due date
      homeWorks = site.data["homeworks"].map { |homework|
        orderNumber = orderNumber + 1
        HomeWork.new(id: homework["id"], dueDate: parseDate(homework["dueDate"]), orderNumber: orderNumber)
      }
      homeWorksReviews = site.data["homework-reviews"].map { |review|
        HomeWorkReview.new(homeWorkId: review["homeworkId"], mentorId: review["mentorId"], studentId: review["studentId"], homeworkCompletedDate: parseDate(review["homeworkCompleted"]))
      }
      ratingCalculator.withHomeworks(homeWorks: homeWorks, homeworkReviews: homeWorksReviews)

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
      return Date.strptime("12/22/2011", "%m/%d/%Y")
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