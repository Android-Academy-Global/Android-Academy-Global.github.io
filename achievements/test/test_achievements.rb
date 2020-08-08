require 'minitest/autorun'
require 'achievements'

include Achievements

$testStudents = [Student.new(telegramId: "student1", name: "test1"), Student.new(telegramId: "student2", name: "test 2")]

class AchievementsTest < Minitest::Test

  def setup
    @calculator = AchievementsCalculator.new()
  end

  def test_students_without_homeworks
    calculatedRating = @calculator.withStudents($testStudents).calculate()
    assert_equal ["student1", "student2"], calculatedRating.studentsRating.map { |r| r.student.telegramId }
    calculatedRating.studentsRating.each { |r| assert_equal(1, r.position) }
  end

  def test_student_completed_one_homework_in_time
      homeworks = [
        HomeWork.new(id: "test homework", dueDate: DateTime.new(2000,9,15))
      ]
      homeworkReviews = [
        HomeWorkReview.new(homeWorkId: homeworks[0].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,16)),
        HomeWorkReview.new(homeWorkId: homeworks[0].id, mentorId: "test", studentId: $testStudents[1].telegramId, homeworkCompletedDate: DateTime.new(2000,9,14))
      ]

      studentsRating = @calculator
        .withStudents($testStudents)
        .withHomeworks(homeWorks: homeworks, homeworkReviews: homeworkReviews)
        .calculate()
        .studentsRating
      
      assert_equal 1, studentsRating[0].position
      assert_equal "student2", studentsRating[0].student.telegramId
      
      assert_equal "student1", studentsRating[1].student.telegramId
      assert_equal 1, studentsRating[1].position
  end
end