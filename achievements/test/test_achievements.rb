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
      assert_equal List::HOME_WORK_COMPLETED_1, studentsRating[0].achievements[0].achievement
      assert_equal List::HOME_WORK_COMPLETED_1.value, studentsRating[0].totalScore
      
      assert_equal "student1", studentsRating[1].student.telegramId
      assert_equal 2, studentsRating[1].position
      assert_equal [], studentsRating[1].achievements
      assert_equal 0, studentsRating[1].totalScore

  end

  def test_student_completed_six_homeworks_in_a_row
    homeworks = [
      HomeWork.new(id: "test homework", dueDate: DateTime.new(2000,9,15)),
      HomeWork.new(id: "test homework 2", dueDate: DateTime.new(2000,9,20)),
      HomeWork.new(id: "test homework 3", dueDate: DateTime.new(2000,9,25)),
      HomeWork.new(id: "test homework 4", dueDate: DateTime.new(2000,10,1)),
      HomeWork.new(id: "test homework 5", dueDate: DateTime.new(2000,10,5)),
      HomeWork.new(id: "test homework 6", dueDate: DateTime.new(2000,10,10))
    ]
    homeworkReviews = [
      HomeWorkReview.new(homeWorkId: homeworks[0].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,14)),
      HomeWorkReview.new(homeWorkId: homeworks[1].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,19)),
      HomeWorkReview.new(homeWorkId: homeworks[2].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,24)),
      HomeWorkReview.new(homeWorkId: homeworks[3].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,30)),
      HomeWorkReview.new(homeWorkId: homeworks[4].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,3)),
      HomeWorkReview.new(homeWorkId: homeworks[5].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,7))
    ]

    studentsRating = @calculator
      .withStudents($testStudents)
      .withHomeworks(homeWorks: homeworks, homeworkReviews: homeworkReviews)
      .calculate()
      .studentsRating

    firstStudentRating = studentsRating[0]
    
    assert_equal 1, firstStudentRating.position
    assert_equal "student1", firstStudentRating.student.telegramId
    
    expectedAchivements = [
      List::HOME_WORK_COMPLETED_1,
      List::HOME_WORK_COMPLETED_2,
      List::HOME_WORK_COMPLETED_3,
      List::HOME_WORK_COMPLETED_4,
      List::HOME_WORK_COMPLETED_5,
      List::HOME_WORK_COMPLETED_1
    ]
    actualAchievements = firstStudentRating.achievements.map { |sa| sa.achievement }
    assert_equal(
      expectedAchivements,
      actualAchievements
    )
  end
end