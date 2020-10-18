require 'minitest/autorun'
require 'achievements'

include Achievements

$testStudents = [Student.new(telegramId: "student1", name: "test1"), Student.new(telegramId: "student2", name: "test 2")]

$testHomeworks = [
  HomeWork.new(id: "test_homework", name: "test homework", dueDate: DateTime.new(2000,9,15), orderNumber: 0),
  HomeWork.new(id: "test_homework_2", name: "test homework 2", dueDate: DateTime.new(2000,9,20), orderNumber: 1),
  HomeWork.new(id: "test_homework_3", name: "test homework 3", dueDate: DateTime.new(2000,9,25), orderNumber: 2),
  HomeWork.new(id: "test_homework_4", name: "test homework 4", dueDate: DateTime.new(2000,10,1), orderNumber: 3),
  HomeWork.new(id: "test_homework_5", name: "test homework 5", dueDate: DateTime.new(2000,10,5), orderNumber: 4),
  HomeWork.new(id: "test_homework_6", name: "test homework 6", dueDate: DateTime.new(2000,10,10), orderNumber: 5)
]

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
        HomeWork.new(id: "test_homework", name: "test", dueDate: DateTime.new(2000,9,15), orderNumber: 0)
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
      assert_equal "For completing homework from test workshop", studentsRating[0].achievements[0].achievementReason
      assert_equal List::HOME_WORK_COMPLETED_1.value, studentsRating[0].totalScore
      
      assert_equal "student1", studentsRating[1].student.telegramId
      assert_equal 2, studentsRating[1].position
      assert_equal [], studentsRating[1].achievements
      assert_equal 0, studentsRating[1].totalScore

  end

  def test_not_completed_homework_breaks_the_stuck
    homeworkReviews = [
      HomeWorkReview.new(homeWorkId: $testHomeworks[0].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,14)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[1].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,19)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[2].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,24)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[4].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,3)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[5].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,7))
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
      HomeWorkReview.new(homeWorkId: $testHomeworks[0].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,14)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[1].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,19)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[2].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,24)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[3].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,9,30)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[4].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,3)),
      HomeWorkReview.new(homeWorkId: $testHomeworks[5].id, mentorId: "test", studentId: $testStudents[0].telegramId, homeworkCompletedDate: DateTime.new(2000,10,7))
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
    
    helps = [StudentHelp.new(studentIdHowHelped: "student2", studentIdWhoGotHelp: "student1", comment: "test comment")]
    
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

  def test_students_attended_workshops
    
    firstAttendeeList = [
      WorkshopAttending.new(workshopId: "workshop1", studentId: "student1", timestamp: DateTime.new(2000,9,20))
    ]
    secondAttendeeList = [
      WorkshopAttending.new(workshopId: "workshop2", studentId: "student2", timestamp: DateTime.new(2000,9,20))
    ]
    homeWorks = [
      HomeWork.new(id: "workshop1", name: "The first workshop", dueDate: DateTime.new(2000,9,15), orderNumber: 0),
      HomeWork.new(id: "workshop2", name: "The second workshop", dueDate: DateTime.new(2000,9,20), orderNumber: 1),
    ]
    
    studentsRating = @calculator
      .withStudents($testStudents)
      .withHomeworks(homeWorks: homeWorks, homeworkReviews: [])
      .addWorkshopAttendees(firstAttendeeList)
      .addWorkshopAttendees(secondAttendeeList)
      .calculate()
      .studentsRating

    firstStudentAchievement = studentsRating[0].achievements[0]
    secondStudentAchievemt = studentsRating[1].achievements[0]
    
    assert_equal(
      "For beeing a part of The first workshop",
      firstStudentAchievement.achievementReason
    )
    assert_equal(
      List::ATTENDED_WORKSHOP,
      firstStudentAchievement.achievement
    )
    assert_equal(
      "For beeing a part of The second workshop",
      secondStudentAchievemt.achievementReason
    )
    assert_equal(
      List::ATTENDED_WORKSHOP,
      secondStudentAchievemt.achievement
    )
  end

  def test_students_attended_workshops_only_once
    
    attendeeList = [
      WorkshopAttending.new(workshopId: "workshop1", studentId: "student1", timestamp: DateTime.new(2000,9,20)),
      WorkshopAttending.new(workshopId: "workshop1", studentId: "student1", timestamp: DateTime.new(2000,9,20)),
      WorkshopAttending.new(workshopId: "workshop1", studentId: "student1", timestamp: DateTime.new(2000,9,20))
    ]
    homeWorks = [
      HomeWork.new(id: "workshop1", name: "the first workshop", dueDate: DateTime.new(2000,9,15), orderNumber: 0)
    ]
    
    studentsRating = @calculator
      .withStudents($testStudents)
      .withHomeworks(homeWorks: homeWorks, homeworkReviews: [])
      .addWorkshopAttendees(attendeeList)
      .calculate()
      .studentsRating

    assert_equal(1, studentsRating[0].achievements.size)
  end
end