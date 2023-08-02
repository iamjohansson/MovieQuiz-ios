import Foundation

// Фактори для запросов к URLSession на основе выбранного api (imdb, kinopoisk)
protocol MoviesRequestFactoryProtocol {
    func constructRequest(apiType: ApiType) -> URLRequest?
}

class MoviesRequestFactory: MoviesRequestFactoryProtocol {
    func constructRequest(apiType: ApiType) -> URLRequest? {
        switch apiType {
        case .imdb:
            if let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_zcuw1ytf") {
                return URLRequest(url: url)
            } else {
                return nil
            }
        case .kp:
            var components = URLComponents(string: "https://api.kinopoisk.dev/v1.3/movie")!
            components.queryItems = [
                URLQueryItem(
                    name: "selectFields",
                    value: ["id", "name", "rating", "poster"].joined(separator: " ")
                ),
                URLQueryItem(name: "limit", value: "20"),
                URLQueryItem(name: "typeNumber", value: "1"),
                URLQueryItem(name: "top250", value: "!null")
        
            ]
            var request = URLRequest(url: components.url!)
            request.addValue("8AGCWPF-ZVQMG1D-M7MFNKE-VVYR39A", forHTTPHeaderField: "X-API-KEY")
            return request
        }
    }
}
