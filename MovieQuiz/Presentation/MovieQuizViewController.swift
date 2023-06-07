import UIKit

private struct QuizQuestion {
    //Строка с неймом фильма
    let image: String
    //Строка с вопросом о рейтинге
    let text: String
    //Булевое значение, правильный ли ответ
    let correctAnswer: Bool
}
private struct QuizStepViewModel {
    // картинка с афишей фильма
    let image: UIImage
    // вопрос о рейтинге квиза
    let question: String
    // строка с порядковым номером этого вопроса (пр. 1/10)
    let questionNumber: String
}
private struct QuizResultsViewModel {
    // строка с заголовком алерта
    let title: String
    // строка с текстом о количестве набранных очков
    let text: String
    // текст для кнопки алерта
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        newQuestion()
        feedbackGenerator = UINotificationFeedbackGenerator()
    }
    //переменная с генеротором, для тактильного отклика
    var feedbackGenerator: UINotificationFeedbackGenerator?
    //переменная с индексом вопроса
    private var currentQuestionIndex = 0
    //переменная со счетчиком верных ответов
    private var correctAnswer = 0
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    private func newQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let convertResult = convert(model: currentQuestion)
        show(quiz: convertResult)
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    // Метод отображения результата ответа с подсчетом количества верных решений
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        buttonEnable()
        if questions[currentQuestionIndex].correctAnswer == isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswer += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResult()
            self.imageView.layer.borderWidth = 0
            self.buttonEnable()
        }
    }
    // Метод для блокировки кнопок, при ожидании перехода к след. вопросу
    private func buttonEnable() {
        if imageView.layer.borderWidth >= 1 {
            noButton.isEnabled = false
            yesButton.isEnabled = false
        } else {
            noButton.isEnabled = true
            yesButton.isEnabled = true
        }
    }
    // Метод перехода к некст вопросу или алерт с результатом
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questions.count - 1 {
            showAlert(quiz: QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат: \(correctAnswer)/10", buttonText: "Сыграть еще раз?"))
        } else {
            currentQuestionIndex += 1
            newQuestion()
        }
    }
    // Алерт всплывающего окна, сообщающий результат
    private func showAlert(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswer = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let convertResult = self.convert(model: firstQuestion)
            self.show(quiz: convertResult)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: true)
        feedbackGenerator?.notificationOccurred(.success)
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: false)
        feedbackGenerator?.notificationOccurred(.success)
    }
}
