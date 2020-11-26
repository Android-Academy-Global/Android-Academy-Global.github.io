require 'minitest/autorun'
require 'achievements'
require_relative 'AchievementsCalculatorTestDataBuilder.rb'

include Achievements

$testStudents = [Student.new(telegramId: TelegramName.new("student1"), name: "test1"), Student.new(telegramId: TelegramName.new("student2"), name: "test 2")]

$testHomeworks = [
  HomeWork.new(id: "test_homework", name: "test homework", dueDate: DateTime.new(2000,9,15), orderNumber: 0),
  HomeWork.new(id: "test_homework_2", name: "test homework 2", dueDate: DateTime.new(2000,9,20), orderNumber: 1),
  HomeWork.new(id: "test_homework_3", name: "test homework 3", dueDate: DateTime.new(2000,9,25), orderNumber: 2),
  HomeWork.new(id: "test_homework_4", name: "test homework 4", dueDate: DateTime.new(2000,10,1), orderNumber: 3),
  HomeWork.new(id: "test_homework_5", name: "test homework 5", dueDate: DateTime.new(2000,10,5), orderNumber: 4),
  HomeWork.new(id: "test_homework_6", name: "test homework 6", dueDate: DateTime.new(2000,10,10), orderNumber: 5)
]

$testMentorId = TelegramName.new("testMentor")

class AchievementsTest < Minitest::Test

  def setup
    @testData = AchievementsCalculatorTestDataBuilder.new()
    @calculator = AchievementsCalculator.new()
  end

  def flushTestData
    @testData.fillupCalculatorWithData(@calculator)
  end

  def test_students_without_homeworks
    first = @testData.addStudent()
    second = @testData.addStudent()
    flushTestData()

    calculatedRating = @calculator.calculate()

    assert_equal [first, second], calculatedRating.studentsRating.map { |r| r.student }
    calculatedRating.studentsRating.each { |r| assert_equal(1, r.position) }
  end

  def test_one_student_completed_homework_second_later_but_perfect
    firstStudent = @testData.addStudent()
    secondStudent = @testData.addStudent()
    workshop = @testData.addWorkshop(name: "test")
    @testData.studentCompletedHomeworkOnTime(firstStudent, workshop)
    @testData.studentCompletedHomeworkAfterDueDate(secondStudent, workshop, mark: 10)
    flushTestData()
    
    studentsRating = @calculator.calculate().studentsRating
    
    assert_equal 1, studentsRating[0].position
    assert_equal firstStudent, studentsRating[0].student
    assert_equal List::HOME_WORK_COMPLETED_1, studentsRating[0].achievements[0].achievement
    assert_equal "For completing homework from test workshop", studentsRating[0].achievements[0].achievementReason
    assert_equal List::HOME_WORK_COMPLETED_1.value, studentsRating[0].totalScore
    
    expextedScroreForFirstStudent = List::LATE_HOMEWORK.value + List::EXCELLENT_HOMEWORK.value
    assert_equal secondStudent, studentsRating[1].student
    assert_equal expextedScroreForFirstStudent, studentsRating[1].totalScore
    assert_equal 2, studentsRating[1].position
    assert_equal 2, studentsRating[1].achievements.size
    assert_equal List::LATE_HOMEWORK, studentsRating[1].achievements[0].achievement
    assert_equal "For completing homework from test workshop", studentsRating[1].achievements[0].achievementReason

    assert_equal List::EXCELLENT_HOMEWORK, studentsRating[1].achievements[1].achievement
    assert_equal "For excellence in homework from test workshop", studentsRating[1].achievements[1].achievementReason
  end

  def test_late_homework_breaks_the_stuck
    student = @testData.addStudent()
    6.times { |time|
      workshop = @testData.addWorkshop()
      if time == 3
        @testData.studentCompletedHomeworkAfterDueDate(student, workshop)
      else
        @testData.studentCompletedHomeworkOnTime(student, workshop)
      end

    }
    flushTestData()


    studentsRating = @calculator.calculate().studentsRating

    firstStudentRating = studentsRating[0]
    assert_equal 1, firstStudentRating.position
    assert_equal student, firstStudentRating.student
    
    expectedAchivements = [
      List::HOME_WORK_COMPLETED_1,
      List::HOME_WORK_COMPLETED_2,
      List::HOME_WORK_COMPLETED_3,
      List::LATE_HOMEWORK,
      List::HOME_WORK_COMPLETED_1,
      List::HOME_WORK_COMPLETED_2
    ]
    actualAchievements = firstStudentRating.achievements.map { |sa| sa.achievement }
    assert_equal(
      expectedAchivements,
      actualAchievements
    )
  end

  def test_not_completed_homework_breaks_the_stuck
    homeworkReviews = [
      HomeWorkReview.new(homeWorkId: $testHomeworks[0].id, mentorId: $testMentorId, studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,14), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[1].id, mentorId: $testMentorId, studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,19), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[2].id, mentorId: $testMentorId, studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,24), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[4].id, mentorId: $testMentorId, studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,3), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[5].id, mentorId: $testMentorId, studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,7), mark: 5)
    ]

    studentsRating = @calculator
      .withStudents($testStudents)
      .withHomeworks(homeWorks: $testHomeworks, homeworkReviews: homeworkReviews)
      .calculate()
      .studentsRating

    firstStudentRating = studentsRating[0]
    
    assert_equal 1, firstStudentRating.position
    assert_equal "student1", firstStudentRating.student.telegramId
    
    expectedAchivements = [
      List::HOME_WORK_COMPLETED_1,
      List::HOME_WORK_COMPLETED_2,
      List::HOME_WORK_COMPLETED_3,
      List::HOME_WORK_COMPLETED_1,
      List::HOME_WORK_COMPLETED_2
    ]
    actualAchievements = firstStudentRating.achievements.map { |sa| sa.achievement }
    assert_equal(
      expectedAchivements,
      actualAchievements
    )
  end

  def test_student_completed_six_homeworks_in_a_row
    
    homeworkReviews = [
      HomeWorkReview.new(homeWorkId: $testHomeworks[0].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,14), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[1].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,19), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[2].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,24), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[3].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,30), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[4].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,3), mark: 5),
      HomeWorkReview.new(homeWorkId: $testHomeworks[5].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,7), mark: 5)
    ]

    studentsRating = @calculator
      .withStudents($testStudents)
      .withHomeworks(homeWorks: $testHomeworks, homeworkReviews: homeworkReviews)
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

  def test_student_help_student
    
    helps = [StudentHelp.new(studentIdHowHelped: TelegramName.new("student2"), studentIdWhoGotHelp: TelegramName.new("student1"), comment: "test comment")]
    
    studentsRating = @calculator
      .withStudents($testStudents)
      .withStudentsHelp(helps)
      .calculate()
      .studentsRating

    helpingHandAchievement = studentsRating[0].achievements[0]
    
    assert_equal(
      "Comment from test1: test comment",
      helpingHandAchievement.achievementReason
    )
    assert_equal(
      List::HELPING_HAND,
      helpingHandAchievement.achievement
    )
  end

  def test_students_left_feedback
    
    firstFeedbackList = [
      WorkshopFeedback.new(workshopId: "workshop1", studentId: TelegramName.new("student1"), timestamp: DateTime.new(2000,9,20), toImprove: "")
    ]
    secondFeedbackList = [
      WorkshopFeedback.new(workshopId: "workshop2", studentId: TelegramName.new("student2"), timestamp: DateTime.new(2000,9,20), toImprove: "test")
    ]
    homeWorks = [
      HomeWork.new(id: "workshop1", name: "The first workshop", dueDate: DateTime.new(2000,9,15), orderNumber: 0),
      HomeWork.new(id: "workshop2", name: "The second workshop", dueDate: DateTime.new(2000,9,20), orderNumber: 1),
    ]
    
    studentsRating = @calculator
      .withStudents($testStudents)
      .withHomeworks(homeWorks: homeWorks, homeworkReviews: [])
      .addWorkshopFeedbacks(firstFeedbackList)
      .addWorkshopFeedbacks(secondFeedbackList)
      .calculate()
      .studentsRating

    firstStudentsAchievements = studentsRating.detect {|s| s.student.telegramId == "student1"}.achievements
    assert_equal 1, firstStudentsAchievements.size
    firstStudentAchievement = firstStudentsAchievements[0]
    assert_equal(
      "For beeing a part of The first workshop",
      firstStudentAchievement.achievementReason
    )
    assert_equal(
      List::ATTENDED_WORKSHOP,
      firstStudentAchievement.achievement
    )

    secondStudentsAchievements = studentsRating.detect {|s| s.student.telegramId == "student2"}.achievements
    secondStudentAttendAchievemt = secondStudentsAchievements.detect {|sa| sa.achievement == List::ATTENDED_WORKSHOP}
    assert_equal(
      "For beeing a part of The second workshop",
      secondStudentAttendAchievemt.achievementReason
    )

    secondStudentCriticAchievemt = secondStudentsAchievements.detect {|sa| sa.achievement == List::CRITIC}
    assert_equal(
      "For helping us improve The second workshop",
      secondStudentCriticAchievemt.achievementReason
    )
  end

  def test_students_left_many_feedbacks
    feedbackList = [
      WorkshopFeedback.new(workshopId: "workshop1", studentId: TelegramName.new("student1"), timestamp: DateTime.new(2000,9,20), toImprove: nil),
      WorkshopFeedback.new(workshopId: "workshop1", studentId: TelegramName.new("student1"), timestamp: DateTime.new(2000,9,20), toImprove: nil),
      WorkshopFeedback.new(workshopId: "workshop1", studentId: TelegramName.new("student1"), timestamp: DateTime.new(2000,9,20), toImprove: nil)
    ]
    homeWorks = [
      HomeWork.new(id: "workshop1", name: "the first workshop", dueDate: DateTime.new(2000,9,15), orderNumber: 0)
    ]
    
    studentsRating = @calculator
      .withStudents($testStudents)
      .withHomeworks(homeWorks: homeWorks, homeworkReviews: [])
      .addWorkshopFeedbacks(feedbackList)
      .calculate()
      .studentsRating

    assert_equal(1, studentsRating[0].achievements.size)
  end

  def test_students_left_best_question
    bestQuestions = [
      BestQuestion.new(workshopId: "workshop1", studentId: TelegramName.new("student1"), linkToQuestion: ""),
      BestQuestion.new(workshopId: "workshop1", studentId: TelegramName.new("student1"), linkToQuestion: "http://test.com/q1")
    ]
    homeWorks = [
      HomeWork.new(id: "workshop1", name: "the test", dueDate: DateTime.new(2000,9,15), orderNumber: 0)
    ]
    
    studentsRating = @calculator
      .withStudents($testStudents)
      .withHomeworks(homeWorks: homeWorks, homeworkReviews: [])
      .withBestQuestions(bestQuestions)
      .calculate()
      .studentsRating

    assert_equal(2, studentsRating[0].achievements.size)
    
    bestQuestionAchievement = studentsRating[0].achievements[0]
    assert_equal List::BEST_QUESTION, bestQuestionAchievement.achievement
    assert_equal "For asking very good question at the test workshop.", bestQuestionAchievement.achievementReason

    bestQuestionAchievementWithLink = studentsRating[0].achievements[1]
    assert_equal List::BEST_QUESTION, bestQuestionAchievementWithLink.achievement
    assert_equal "For asking <a href=\"http://test.com/q1\">very good question</a> at the test workshop.", bestQuestionAchievementWithLink.achievementReason
  end
end

class TelegramNameTest < Minitest::Test
  def test_compare_the_same_names()
    first = TelegramName.new("test")
    second = TelegramName.new("test")
    assert first == second
  end

  def test_compare_names_with_space()
    first = TelegramName.new("test")
    second = TelegramName.new("test ")
    assert first == second
  end

  def test_compare_names_with_without_at()
    first = TelegramName.new("@test")
    second = TelegramName.new("test")
    assert first == second
  end

  def test_compare_names_with_with_different_case()
    first = TelegramName.new("@TestTest")
    second = TelegramName.new("@testtest")
    assert first == second
  end

  def test_convert_telegram_name_to_string()
    name = TelegramName.new("@TestTest")
    concatedString = "test " + name
    assert_equal "test @TestTest", concatedString
  end

  def test_convert_telegram_name_to_string_for_liquid()
    name = TelegramName.new("@TestTest")
    assert_equal "@TestTest", name.to_s
  end

  def test_hashes()
    first = TelegramName.new("@Test")
    second = TelegramName.new("test")
    assert_equal first.hash, second.hash
  end

  def test_hashtables()
    hash = { TelegramName.new("@Test1") => 1, TelegramName.new("test2") => 2 }
    assert_equal 2, hash[TelegramName.new("test2")]
  end

  def test_compare_with_string()
    assert_equal TelegramName.new("@Test"), "@Test"
  end
end