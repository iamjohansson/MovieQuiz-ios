import Foundation

// Хандлер для парса даты на основе api (imdb, kinopoisk) с возвратом массива фильмов
protocol MoviesResponceHandlerProtocol {
    func handlerResponce(_ data: Data, apiType: ApiType) throws -> [Movie]
}

class MoviesResponceHandler: MoviesResponceHandlerProtocol {
    func handlerResponce(_ data: Data, apiType: ApiType) throws -> [Movie] {
        switch apiType {
        case .imdb:
            let responce = try JSONDecoder().decode(MostPopularMovies.self, from: data)
            return responce.items
        case .kp:
            let responce = try JSONDecoder().decode(KPMoviesResponce.self, from: data)
            return responce.docs
        }
    }
}
