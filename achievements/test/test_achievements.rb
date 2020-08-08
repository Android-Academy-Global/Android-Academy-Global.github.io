require 'minitest/autorun'
require 'achievements'

include Achievements

class AchievementsTest < Minitest::Unit::TestCase
  def test_sudents_without_homeworks
    students = [Student.new(telegramId: "student1", name: "test1"), Student.new(telegramId: "student2", name: "test 2")]

    calculator = AchievementsCalculator.new()
    calculator.withStudents(students)
    calculatedRating = calculator.calculate()
    assert_equal ["student1", "student2"], calculatedRating.studentsRating.map { |r| r.student.telegramId }
  end
end