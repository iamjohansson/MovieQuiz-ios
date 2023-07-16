import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showAlertMessage()
    func showNetworkError(message: String)
    func show(quiz step: QuizStepViewModel)
    func showImageViewBorderAndIndicator(isCorrectAnswer: Bool)
    func hideImageViewBorderAndIndicator()
}
