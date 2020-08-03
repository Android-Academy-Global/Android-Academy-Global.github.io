require "achievements"

module Rating

  class RatingDataGenerator < Jekyll::Generator
    def generate(site)
      ratingTemplate = site.pages.detect {|page| page.name == 'rating.html'}
      puts "hi"
      students = site.data["students"].map { |student|
          Student.new(telegramId: student["telegramId"], name: student["name"])
      }
      rating = Achievements.calculateRating(students)
      ratingTemplate.data["rating"] = rating
    end
  end
end