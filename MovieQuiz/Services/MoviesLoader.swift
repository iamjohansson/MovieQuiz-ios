import Foundation

enum ApiType {
    case imdb, kp
}

protocol MoviesLoading {
    var api: ApiType { get set }
    func loadMovies(handler: @escaping (Result<[Movie], Error>) -> Void)
}

class MoviesLoader: MoviesLoading {

    var api: ApiType = .imdb
    private lazy var requestFactory: MoviesRequestFactoryProtocol = MoviesRequestFactory()
    private lazy var responceHandler: MoviesResponceHandlerProtocol = MoviesResponceHandler()
    
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    var request: URLRequest? {
        requestFactory.constructRequest(apiType: api)
    }
    
    func loadMovies(handler: @escaping (Result<[Movie], Error>) -> Void) {
        guard let request = request else {
            handler(.failure(NetworkError.brokenRequest))
            return
        }
        networkClient.fetch(request: request) { [unowned self] result in
            switch result {
            case.success(let data):
                do {
                    let result = try responceHandler.handlerResponce(data, apiType: api)
                    handler(.success(result))
                } catch {
                    handler(.failure(error))
                }
            case.failure(let error):
                handler(.failure(error))
            }
        }
    }
}
