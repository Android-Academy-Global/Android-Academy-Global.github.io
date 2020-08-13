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

      homeWorks = site.data["homeworks"].map { |homework|
          HomeWork.new(id: homework["id"], dueDate: parseDate(homework["dueDate"]))
      }
      homeWorksReviews = site.data["homework-reviews"].map { |review|
        HomeWorkReview.new(homeWorkId: review["homeworkId"], mentorId: review["mentorId"], studentId: review["studentId"], homeworkCompletedDate: parseDate(review["homeworkCompleted"]))
      }
      ratingCalculator.withHomeworks(homeWorks: homeWorks, homeworkReviews: homeWorksReviews)

      rating = ratingCalculator.calculate().studentsRating
      ratingTemplate.data["rating"] = rating
    end

    def parseDate(date)
      return Date.strptime("12/22/2011", "%m/%d/%Y")
    end
  end
end