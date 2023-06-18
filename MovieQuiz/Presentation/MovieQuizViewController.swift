import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    private let questionAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresentation: AlertPresentationProtocol?
    private var statisticService: StatisticService?
    // Обработка статус бара
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresentation = AlertPresentation(delegate: self)
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - Delegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let convertResult = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: convertResult)
        }
    }
    
    private func showAlertMessage() {
        statisticService?.store(correct: correctAnswer, total: questionAmount)
        let alertMessage = AlertModel(title: "Этот раунд окончен!", text: newAlertText(), buttonText: "Сыграть еще раз?", completion: { [weak self] in
            
            self?.currentQuestionIndex = 0
            self?.correctAnswer = 0
            self?.questionFactory?.requestNextQuestion()
        })
        alertPresentation?.showAlert(quiz: alertMessage)
    }
    
    private func newAlertText() -> String {
        guard let statisticService = statisticService else { return "Error!" }
        
        let yourCurrentScore = "Ваш результат: \(correctAnswer)/\(questionAmount)"
        let amountPlayedQuiz = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let yourCurrentRecord = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date.dateTimeString)"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return "\(yourCurrentScore)\n\(amountPlayedQuiz)\n\(yourCurrentRecord)\n\(averageAccuracy)"
    }
    
    // MARK: - Private Functions
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
        )
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
        guard let currentQuestion = currentQuestion else { return }
        if currentQuestion.correctAnswer == isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswer += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
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
        if currentQuestionIndex == questionAmount - 1 {
            showAlertMessage()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: true)
        feedbackGenerator.notificationOccurred(.success)
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: false)
        feedbackGenerator.notificationOccurred(.success)
    }
}

