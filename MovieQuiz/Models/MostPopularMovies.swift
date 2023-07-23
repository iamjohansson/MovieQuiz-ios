import Foundation

protocol Movie {
    var title: String { get }
    var rating: String { get }
    var imageURL: URL { get }
}

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable, Movie {
    let title: String
    let rating: String
    let previewURL: URL
    
    var imageURL: URL {
        let urlString = previewURL.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        guard let newURL = URL(string: imageUrlString) else {
            return self.imageURL
        }
        return newURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case previewURL = "image"
    }
    
}
