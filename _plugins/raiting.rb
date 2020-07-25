module Rating

  class StudentInRating < Liquid::Drop
    def initialize(student, achievements)
      @student = student
      @achievements = achievements
      @score = achievements.map { |a| a["value"] }.reduce(0, :+)
    end

    def student
      @student
    end

    def achievements
      @achievements
    end

    def score
      @score
    end
  end

  class Raiting
    def self.calculateRating(students, achievements)
      achievementsHashTable = {}
      for achievement in achievements
        achievementsHashTable[achievement["id"]] = achievement
      end

      return students
        .map { |student|
          achievementsOfTheStudent = student["achievements"].map { |id| achievementsHashTable[id] }
          StudentInRating.new(student, achievementsOfTheStudent)
        }
        .sort_by {|rating| rating.score * -1}
    end
  end

  class RatingDataGenerator < Jekyll::Generator
    def generate(site)
      ratingTemplate = site.pages.detect {|page| page.name == 'rating.html'}
      puts "hi"
      rating = Raiting.calculateRating(site.data["students"], site.data["achievements"])
      ratingTemplate.data["rating"] = rating
    end
  end
end