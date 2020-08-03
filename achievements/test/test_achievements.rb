require 'minitest/autorun'
require 'achievements'

include Achievements

class AchievementsTest < Minitest::Test
  def test_students_rating
    students = [Student.new(telegramId: "student1", name: "test1"), Student.new(telegramId: "student2", name: "test 2")]
    rating = AchievementsCalculator.calculateRating(students)
    assert_equal "test1", rating[0].student.name
  end
end