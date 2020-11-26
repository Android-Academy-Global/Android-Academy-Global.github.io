class AchievementsCalculatorTestDataBuilder

    def initialize
        @students = []
        @workshops = []
        @homeworkReviews = []
        @workshops = []
        @feedbacks = Hash.new
        @firstWorkshopHomeworkDueDateDate = DateTime.new(2000,1,10)
        @testMentorId = "test-mentor"
        @studentHelps = []
        @bestQuestions = []
    end

    def addStudent
        studentNumber = @students.size
        student = Student.new(telegramId: TelegramName.new("student#{studentNumber}TelegramName"), name: "student#{studentNumber}Name")
        @students.push(student)
        return student
    end

    def addWorkshop(name: nil)
        workshopNumber = @workshops.size
        homeworkDueDate = @firstWorkshopHomeworkDueDateDate + (5 * workshopNumber)
        workshop = HomeWork.new(id: "test_homework_#{workshopNumber}", name: name || "test homework #{workshopNumber}", dueDate: homeworkDueDate, orderNumber: workshopNumber)
        @workshops.push(workshop)
        @feedbacks[workshop.id] = []
        return workshop
    end

    def studentCompletedHomeworkOnTime(student, workshop, mark: 5)
        homeworkReview = HomeWorkReview.new(
            homeWorkId: workshop.id,
            mentorId: @testMentorId,
            studentId: student.telegramId,
            homeworkCompletedDate: workshop.dueDate - 1,
            mark: mark
        )
        @homeworkReviews.push(homeworkReview)
    end

    def studentCompletedHomeworkAfterDueDate(student, workshop, mark: 5)
        homeworkReview = HomeWorkReview.new(
            homeWorkId: workshop.id,
            mentorId: @testMentorId,
            studentId: student.telegramId,
            homeworkCompletedDate: workshop.dueDate + 1,
            mark: mark
        )
        @homeworkReviews.push(homeworkReview)
    end

    def studentHelpedStudent(from:, to:, comment: "test comment")
        help = StudentHelp.new(
            studentIdHowHelped: to.telegramId,
            studentIdWhoGotHelp: from.telegramId,
            comment: comment
        )
        @studentHelps.push(help)
    end

    def studentLeftFeedback(sudent, workshop, toImprove: "")
        feedback = WorkshopFeedback.new(
            workshopId: workshop.id,
            studentId: sudent.telegramId,
            timestamp: DateTime.new(2001,1,10),
            toImprove: toImprove
        )
        @feedbacks[workshop.id].push(feedback)
    end


    def studentLeftBestQuestion(student, workshop, linkToQuestion: "")
        question = BestQuestion.new(
            workshopId: workshop.id,
            studentId: student.telegramId,
            linkToQuestion: linkToQuestion
        )
        @bestQuestions.push(question)
    end

    def fillupCalculatorWithData(calculator)
        calculator.withStudents(@students)
            .withHomeworks(homeWorks: @workshops, homeworkReviews: @homeworkReviews)
            .withStudentsHelp(@studentHelps)
            .withBestQuestions(@bestQuestions)
        @feedbacks.each { |key, value|
            calculator.addWorkshopFeedbacks(value)    
        }
    end
end