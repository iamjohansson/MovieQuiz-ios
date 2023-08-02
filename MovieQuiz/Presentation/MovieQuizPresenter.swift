import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    var correctAnswer = 0
    let questionAmount = 10
    private weak var viewController: MovieQuizViewController?
    let statisticService: StatisticService!
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    private var moviesLoading: MoviesLoading
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
        self.moviesLoading = MoviesLoader()
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    func didLoadDataFromServer() {
        viewController?.indicatorStopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didFailToLoadImage(with error: Error) {
        let message = error.localizedDescription
        viewController?.showImageError(message: message)
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    func yesButtonClicked() {
        showAnswerResult(isCorrect: true)
    }
    
    func noButtonClicked() {
        showAnswerResult(isCorrect: false)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        if currentQuestion.correctAnswer == isCorrect {
            viewController?.showImageViewBorderAndIndicator(isCorrectAnswer: isCorrect)
            correctAnswer += 1
        } else {
            viewController?.showImageViewBorderAndIndicator(isCorrectAnswer: isCorrect)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.hideImageViewBorderAndIndicator()
            self.showNextQuestionOrResult()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let convertResult = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: convertResult)
        }
    }
    
    private func showNextQuestionOrResult() {
        if self.isLastQuestion() {
            viewController?.showAlertMessage()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func switchApi() -> ApiType {
        if moviesLoading.api == .imdb {
            moviesLoading.api = .kp
        } else {
            moviesLoading.api = .imdb
        }
        return moviesLoading.api
    }
    
    func alertText() -> String {
        guard let statisticService = statisticService else { return "Error!" }
        
        let yourCurrentScore = "Ваш результат: \(correctAnswer)/\(questionAmount)"
        let amountPlayedQuiz = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let yourCurrentRecord = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return "\(yourCurrentScore)\n\(amountPlayedQuiz)\n\(yourCurrentRecord)\n\(averageAccuracy)"
    }
}
