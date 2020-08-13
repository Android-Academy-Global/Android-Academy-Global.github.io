require "achievements"

module Rating

  class RatingDataGenerator < Jekyll::Generator
    def generate(site)
      ratingTemplate = site.pages.detect {|page| page.name == 'rating.html'}
      ratingCalculator = Achievements.new()

      students = site.data["students"].map { |student|
          Student.new(telegramId: student["telegramId"], name: student["name"])
      }

      homeWorks = site.data["homeworks"].map { |homework|
          HomeWork.new(id: homework["id"], dueDate: DateTime.parse(homework["dueDate"]))
      }
      homeWorksReviews = site.data["homework-reviews"].map { |review|
        HomeWorkReview.new(homeWorkId: review["homeworkId"], mentorId: review["mentorId"], studentId: review["studentId"], homeworkCompletedDate: DateTime.parse(review[homeworkCompleted]))
      }
      ratingCalculator.withHomeworks(homeWorks: homeWorks, homeworkReviews: homeWorksReviews)

      rating = ratingCalculator.calculate().studentsRating
      ratingTemplate.data["rating"] = rating
    end
  end
end