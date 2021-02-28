require 'minitest/autorun'
require 'achievements'
require_relative 'AchievementsCalculatorTestDataBuilder.rb'
include Achievements

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
    student = @testData.addStudent()
    6.times { |time|
      workshop = @testData.addWorkshop()
      if time == 3
        # homework not completed
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
    student = @testData.addStudent()
    6.times { |time|
      workshop = @testData.addWorkshop()
      @testData.studentCompletedHomeworkOnTime(student, workshop)
      if time == 3
        @testData.studentCompletedHomeworkOnTime(student, workshop) # few review of the same homework shouldn't affect anything
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
    firstStudent = @testData.addStudent()
    secondStudent = @testData.addStudent()
    @testData.studentHelpedStudent(from: firstStudent, to: secondStudent, comment: "test comment")
    flushTestData()

    studentsRating = @calculator.calculate().studentsRating
    helpingHandAchievement = studentsRating[0].achievements[0]

    assert_equal(
      "Comment from <a href=\"/students/student0TelegramName/\">student0Name</a>: test comment",
      helpingHandAchievement.achievementReason
    )
    assert_equal(
      List::HELPING_HAND,
      helpingHandAchievement.achievement
    )
  end

  def test_students_left_feedback
    firstStudent = @testData.addStudent()
    secondStudent = @testData.addStudent()
    firstWorkshop = @testData.addWorkshop(name: "the first workshop")
    secondWorkshop = @testData.addWorkshop(name: "the second workshop")
    @testData.studentLeftFeedback(firstStudent, firstWorkshop)
    @testData.studentLeftFeedback(secondStudent, secondWorkshop, toImprove: "test to improve")
    flushTestData()

    studentsRating = @calculator.calculate().studentsRating

    firstStudentsAchievements = studentsRating.detect {|s| s.student == firstStudent }.achievements
    assert_equal 1, firstStudentsAchievements.size
    firstStudentAchievement = firstStudentsAchievements[0]
    assert_equal(
      "For beeing a part of the first workshop",
      firstStudentAchievement.achievementReason
    )
    assert_equal(
      List::ATTENDED_WORKSHOP,
      firstStudentAchievement.achievement
    )

    secondStudentsAchievements = studentsRating.detect {|s| s.student == secondStudent}.achievements
    secondStudentAttendAchievemt = secondStudentsAchievements.detect {|sa| sa.achievement == List::ATTENDED_WORKSHOP}
    assert_equal(
      "For beeing a part of the second workshop",
      secondStudentAttendAchievemt.achievementReason
    )

    secondStudentCriticAchievemt = secondStudentsAchievements.detect {|sa| sa.achievement == List::CRITIC}
    assert_equal(
      "For helping us improve the second workshop",
      secondStudentCriticAchievemt.achievementReason
    )
  end

  def test_students_left_many_feedbacks
    student = @testData.addStudent()
    workshop = @testData.addWorkshop()
    5.times {
      @testData.studentLeftFeedback(student, workshop)
    }
    flushTestData()

    studentsRating = @calculator.calculate().studentsRating

    assert_equal(1, studentsRating[0].achievements.size)
  end

  def test_students_left_many_feedbacks_with_different_toImprove_value
    student = @testData.addStudent()
    workshop = @testData.addWorkshop()
    @testData.studentLeftFeedback(student, workshop, toImprove: '')
    @testData.studentLeftFeedback(student, workshop, toImprove: 'test')
    @testData.studentLeftFeedback(student, workshop, toImprove: nil)

    flushTestData()

    studentsRating = @calculator.calculate().studentsRating

    assert_equal(2, studentsRating[0].achievements.size)
  end

  def test_many_students_left_many_feedbacks_with_different_toImprove_value
    student1 = @testData.addStudent()
    student2 = @testData.addStudent()
    workshop = @testData.addWorkshop()
    @testData.studentLeftFeedback(student1, workshop, toImprove: '')
    @testData.studentLeftFeedback(student1, workshop, toImprove: 'test')
    @testData.studentLeftFeedback(student1, workshop, toImprove: nil)

    @testData.studentLeftFeedback(student2, workshop, toImprove: '')
    @testData.studentLeftFeedback(student2, workshop, toImprove: 'test')
    @testData.studentLeftFeedback(student2, workshop, toImprove: nil)

    flushTestData()

    studentsRating = @calculator.calculate().studentsRating

    assert_equal(2, studentsRating[0].achievements.size)
    assert_equal(2, studentsRating[1].achievements.size)
  end

  def test_students_left_best_question
    student = @testData.addStudent()
    workshop = @testData.addWorkshop(name: "the test")
    @testData.studentLeftBestQuestion(student, workshop)
    @testData.studentLeftBestQuestion(student, workshop, linkToQuestion: "http://test.com/q1")
    flushTestData()

    studentsRating = @calculator.calculate().studentsRating

    assert_equal(2, studentsRating[0].achievements.size)

    bestQuestionAchievement = studentsRating[0].achievements[0]
    assert_equal List::BEST_QUESTION, bestQuestionAchievement.achievement
    assert_equal "For asking very good question at the test workshop.", bestQuestionAchievement.achievementReason

    bestQuestionAchievementWithLink = studentsRating[0].achievements[1]
    assert_equal List::BEST_QUESTION, bestQuestionAchievementWithLink.achievement
    assert_equal "For asking <a href=\"http://test.com/q1\">very good question</a> at the test workshop.", bestQuestionAchievementWithLink.achievementReason
  end

  def test_studens_took_part_in_hackathon
    student = @testData.addStudent()
    @testData.studentGotThroughtHackathon(student, "test team")
    flushTestData()

    studentsRating = @calculator.calculate().studentsRating

    hackathonAchievement = studentsRating[0].achievements[0]
    assert_equal List::HACKATHON_PARTICIPANT, hackathonAchievement.achievement
    assert_equal "For getting throught hackathon with \"test team\".", hackathonAchievement.achievementReason
  end

  def test_give_student_achievement_manually
    student1 = @testData.addStudent()
    winndingReason = "for project 1"
    @testData.studentGotManualAchievement(student1, List::HACKATHON_FIRST_PLACE.id, winndingReason)
  
    bestImplementationReason = "For the clean architecture on hackathon"
    @testData.studentGotManualAchievement(student1, List::HACKATHON_BEST_IMPLEMENTATION.id, bestImplementationReason)

    student2 = @testData.addStudent()
    winndingReason2 = "for project 2"
    @testData.studentGotManualAchievement(student2, List::HACKATHON_SECOND_PLACE.id, winndingReason2)
  
    bestIdeaReason = "For the most social idea"
    @testData.studentGotManualAchievement(student2, List::HACKATHON_BEST_IDEA.id, bestIdeaReason)

    flushTestData()

    studentsRating = @calculator.calculate().studentsRating

    winningAchievement = studentsRating[0].achievements[0]
    assert_equal List::HACKATHON_FIRST_PLACE, winningAchievement.achievement
    assert_equal winndingReason, winningAchievement.achievementReason

    bestImplementationAchievement = studentsRating[0].achievements[1]
    assert_equal List::HACKATHON_BEST_IMPLEMENTATION, bestImplementationAchievement.achievement
    assert_equal bestImplementationReason, bestImplementationAchievement.achievementReason

    secondPlaceAchievement = studentsRating[1].achievements[0]
    assert_equal List::HACKATHON_SECOND_PLACE, secondPlaceAchievement.achievement
    assert_equal winndingReason2, secondPlaceAchievement.achievementReason

    bestIdeaAchievement = studentsRating[1].achievements[1]
    assert_equal List::HACKATHON_BEST_IDEA, bestIdeaAchievement.achievement
    assert_equal bestIdeaReason, bestIdeaAchievement.achievementReason
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
