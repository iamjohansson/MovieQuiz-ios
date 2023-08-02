import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showImageError(message: String) {
    }
    
    func showAlertMessage() {
    }

    func showNetworkError(message: String) {
    }

    func show(quiz step: QuizStepViewModel) {
    }

    func showImageViewBorderAndIndicator(isCorrectAnswer: Bool) {
    }

    func hideImageViewBorderAndIndicator() {
    }


}

final class MovieQuizPresenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question text", correctAnswer: true)
        let viewModel = sut.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }

}
