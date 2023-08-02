import Foundation

enum ErrorCase: Error {
    case different(error: String)
    case imageError
}

extension ErrorCase: LocalizedError {
    var errorDescription: String? {
        switch self {
        case.different(let error):
            return NSLocalizedString(error, comment: "Network error")
        case.imageError:
            return NSLocalizedString("Изображение временно недоступно", comment: "Image not available")
        }
    }
}

class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [Movie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies
                    self.delegate?.didLoadDataFromServer()
                case .failure(_):
                    let error: Error = ErrorCase.different(error: "Проверьте настройки сети и попробуйте еще раз")
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Image not available")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let error: Error = ErrorCase.imageError
                    self.delegate?.didFailToLoadImage(with: error)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomRating = round(Float.random(in: 7...9) * 10) / 10
            let valueForQuestion = ["больше", "меньше"]
            guard let moreOrLess = valueForQuestion.randomElement() else { return }
            let text = "Рейтинг этого фильма \(moreOrLess) чем \(randomRating) ?"
            let correctAnswer: Bool = moreOrLess == "больше" ? rating > randomRating : rating < randomRating
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
