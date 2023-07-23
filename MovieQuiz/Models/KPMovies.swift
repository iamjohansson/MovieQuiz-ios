import Foundation

struct KPMoviesResponce: Codable {
    let docs: [KPMovie]
}

struct KPMovie: Codable, Movie {
    let title: String
    let kprating: KPRating
    let poster: KPPoster
    
    var rating: String {
        "\(kprating.imdb)"
    }
    
    var imageURL: URL {
        URL(string: poster.previewURL)!
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "name"
        case kprating = "rating"
        case poster = "poster"
    }
}

struct KPPoster: Codable {
    let url, previewURL: String
    
    enum CodingKeys: String, CodingKey {
        case url
        case previewURL = "previewUrl"
    }
}

struct KPRating: Codable {
    let imdb: Double
}
