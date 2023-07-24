import UIKit


final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private var presenter: MovieQuizPresenter!
    private var alertPresentation: AlertPresentationProtocol?
    
    // Обработка статус бара
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        alertPresentation = AlertPresentation(delegate: self)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        presenter = MovieQuizPresenter(viewController: self)
    }

    // MARK: - Functions
    
    func showAlertMessage() {
        presenter.statisticService?.store(correct: presenter.correctAnswer, total: presenter.questionAmount)
        let alertMessage = AlertModel(title: "Этот раунд окончен!", text: presenter.alertText(), buttonText: "Сыграть еще раз?", completion: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.questionFactory?.requestNextQuestion()
        })
        alertPresentation?.showAlert(quiz: alertMessage)
    }
    
    func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let model = AlertModel(title: "Ошибка загрузки игры", text: message, buttonText: "Попробовать еще раз?") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.questionFactory?.loadData()
        }
        alertPresentation?.showAlert(quiz: model)
    }
    
    func showImageError(message: String) {
        activityIndicator.stopAnimating()
        
        let model = AlertModel(title: "Ошибка", text: message, buttonText: "Обновить!") {
            [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.questionFactory?.requestNextQuestion()
        }
        alertPresentation?.showAlert(quiz: model)
    }
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    func showImageViewBorderAndIndicator(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        activityIndicator.startAnimating()
        buttonEnable()
        imageView.layer.borderColor = presenter.currentQuestion?.correctAnswer == isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    // ниже тестим self
    func hideImageViewBorderAndIndicator() {
        imageView.layer.borderWidth = 0
        activityIndicator.stopAnimating()
        buttonEnable()
    }

    private func buttonEnable() {
        if imageView.layer.borderWidth >= 1 {
            noButton.isEnabled = false
            yesButton.isEnabled = false
        } else {
            noButton.isEnabled = true
            yesButton.isEnabled = true
        }
    }

    func indicatorStopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
        feedbackGenerator.notificationOccurred(.success)
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
        feedbackGenerator.notificationOccurred(.success)
    }
}

