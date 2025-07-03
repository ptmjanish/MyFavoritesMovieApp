//
//  TMDBServices.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 02/07/25.
//



import Foundation
import RealmSwift


enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case noData
    case unauthorized // For 401/403 errors
}

class TMDBService {
    static let shared = TMDBService() // Singleton for easy access
    private let baseURL = "https://api.themoviedb.org/3"
//    private let apiKey = "YOUR_TMDB_API_KEY" // Replace with your actual key
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500" // For movie posters
    private let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0YzVlNGJkY2M1OTc1ZGE4MjcwNTcxYjczNGNmOTc1MiIsIm5iZiI6MTc1MTQ0MDc2My4zNDUsInN1YiI6IjY4NjRkZDdiMmY1ZmUzYzdmNTUzMjU0NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.CQ2NBV6ZsFK1eE4lFdhuMsgPnR7847Qlw_ZyC0SQpIo"

    private init() {} // Private initializer for singleton

    // In TMDBService.swift

    func fetchPopularMovies(page: Int = 1) async throws -> [Movie] {
        // Start with the base URL for components
        guard let baseUrlForComponents = URL(string: "\(baseURL)/movie/popular") else {
            throw NetworkError.invalidURL
        }
        var components = URLComponents(url: baseUrlForComponents, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
              URLQueryItem(name: "page", value: "1")
        ]

        guard let finalURL = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let data = try await performRequest(urlRequest: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(MovieResponse.self, from: data)
            return decodedResponse.results
        }
        catch {
            print("Error fetching movies from API: \(error.localizedDescription)")
            print("Falling back to dummy data...")
            if let dummyResponse = loadDummyResponse() {
                return dummyResponse.results
            } else {
                // If dummy data also failed to load, rethrow the original API error
                print("Failed to load dummy data as well. Re-throwing original error.")
                throw error
            }
        }
    }
    

    func searchMovies(query: String) async throws -> [Movie]{
        
        guard let baseUrlForComponents = URL(string: "\(baseURL)/search/movie") else {
            throw NetworkError.invalidURL
        }
        var components = URLComponents(url: baseUrlForComponents, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "include_adult", value: "false"),
          URLQueryItem(name: "language", value: "en-US"),
          URLQueryItem(name: "page", value: "1"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        
        do {
            let data = try await performRequest(urlRequest: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(MovieResponse.self, from: data)
            return decodedResponse.results
        }
        catch {
            print("Error fetching movies from API: \(error.localizedDescription)")
            print("Falling back to dummy data...")
            if let dummyResponse = loadDummyResponse() {
                return dummyResponse.results
            } else {
                // If dummy data also failed to load, rethrow the original API error
                print("Failed to load dummy data as well. Re-throwing original error.")
                throw error
            }
        }
    }
    
    func getDetails(of movie: Movie) async throws -> MovieDetail {
        guard let baseUrlForComponents = URL(string: "\(baseURL)/movie/\(movie.id)") else {
            throw NetworkError.invalidURL
            
        }
        var components = URLComponents(url: baseUrlForComponents, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "language", value: "en-US"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let data = try await performRequest(urlRequest: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(MovieDetail.self, from: data)
            return decodedResponse
        }
        catch {
            print("Error fetching movies from API: \(error.localizedDescription)")
            print("Falling back to dummy data...")
            if let dummyResponse = loadDummyDetail() {
                return dummyResponse
            } else {
                // If dummy data also failed to load, rethrow the original API error
                print("Failed to load dummy data as well. Re-throwing original error.")
                throw error
            }
        }
        
    }
    
    private func performRequest(urlRequest: URLRequest) async throws -> Data { // <-- Modified signature
        let (data, response) = try await URLSession.shared.data(for: urlRequest) // Use the passed-in request
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw NetworkError.unauthorized
            } else {
                throw NetworkError.invalidResponse
            }
        }
        
        return data
    }
    
    

    // Helper to get full image URL
    func getPosterURL(path: String?) -> URL? {
        guard let path = path else { return nil }
        return URL(string: imageBaseURL + path)
    }
    
    func loadDummyResponse() -> MovieResponse? {
        guard let url = Bundle.main.url(forResource: "dummy_movie_response", withExtension: "json") else {
            print("Error: Could not find dummy_movies_response.json in the app bundle.")
            return nil
        }
        
        do {
            // 2. Read the data from the file
            let data = try Data(contentsOf: url)
            
            // 3. Decode the JSON data into your MovieResponse struct
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(MovieResponse.self, from: data)
            print("Successfully loaded dummy movie data.")
            return decodedResponse
        } catch {
            print("Error decoding dummy movie data: \(error)")
            // Detailed error printing for debugging:
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for \(type): \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found for \(type): \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error: \(error.localizedDescription)")
                }
            }
            return nil
        }
    }
    
    func loadDummyDetail() -> MovieDetail? {
        guard let url = Bundle.main.url(forResource: "dummy_movie_details", withExtension: "json") else {
            print("Error: Could not find dummy_movies_response.json in the app bundle.")
            return nil
        }
        
        do {
            // 2. Read the data from the file
            let data = try Data(contentsOf: url)
            
            // 3. Decode the JSON data into your MovieResponse struct
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(MovieDetail.self, from: data)
            print("Successfully loaded dummy movie data.")
            return decodedResponse
        } catch {
            print("Error decoding dummy movie data: \(error)")
            // Detailed error printing for debugging:
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for \(type): \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found for \(type): \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error: \(error.localizedDescription)")
                }
            }
            return nil
        }
    }
}

// MARK: - Codable Models

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let genreIds: [Int]?
    let adult: Bool
    let backdropPath: String?
    let originalLanguage: String
    let originalTitle: String
    let popularity: Double
    let video: Bool
    let voteCount: Int
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
        case adult
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case popularity
        case video
        case voteCount = "vote_count"
    }
    
    
}


extension Movie {
    init(favoriteMovie: FavoriteMovie) {
        self.id = favoriteMovie.id
        self.title = favoriteMovie.title
        self.overview = favoriteMovie.overview
        self.posterPath = favoriteMovie.posterPath
        self.backdropPath = favoriteMovie.backdropPath
        self.voteAverage = favoriteMovie.voteAverage
        self.releaseDate = favoriteMovie.releaseDate
        self.adult = favoriteMovie.adult
        self.originalLanguage = favoriteMovie.originalLanguage
        self.originalTitle = favoriteMovie.originalTitle
        self.popularity = favoriteMovie.popularity
        self.video = favoriteMovie.video
        self.voteCount = favoriteMovie.voteCount
        self.genreIds = favoriteMovie.genreIds.isEmpty ? nil : Array(favoriteMovie.genreIds)
        self.isFavorite = true
    }
    
    init(movieDetail: MovieDetail) {
        
        self.id = movieDetail.id
        self.title = movieDetail.title
        self.overview = movieDetail.overview ?? ""
        self.posterPath = movieDetail.posterPath
        self.backdropPath = movieDetail.backdropPath
        self.voteAverage = movieDetail.voteAverage
        self.releaseDate = movieDetail.releaseDate
        
        // Convert Swift Array<Int> to Realm List<Int>
        let genreList = List<Int>()
        genreList.append(objectsIn: movieDetail.genres.map { $0.id })
        self.genreIds = genreList.compactMap({$0})
        
        self.adult = movieDetail.adult
        self.originalLanguage = movieDetail.originalLanguage
        self.originalTitle = movieDetail.originalTitle
        self.popularity = movieDetail.popularity
        self.video = movieDetail.video
        self.voteCount = movieDetail.voteCount
    }
}
