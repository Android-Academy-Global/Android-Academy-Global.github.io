module Rating

  class StudentInRating
    def initialize(student, achievements)
      @student = student
      @achievements = achievements
    end

    def student
      @student
    end

    def achievements
      @achievements
    end
  end

  class Raiting
    def self.calculateRating(students, achievements)
      achievementsHashTable = {}
      for achievement in achievements
        achievementsHashTable[achievement["id"]] = achievement
      end

      return students.map { |student|
        achievementsOfTheStudent = student["achievements"].map { |id| achievementsHashTable[id] }
        StudentInRating.new(student, achievementsOfTheStudent)
      }
    end
  end

  class RatingDataGenerator < Jekyll::Generator
    def generate(site)
      ratingTemplate = site.pages.detect {|page| page.name == 'raiting.html'}
      rating = Raiting.calculateRating(site.data["students"], site.data["achievements"])
      ratingTemplate.data["raiting"] = rating
    end
  end
end