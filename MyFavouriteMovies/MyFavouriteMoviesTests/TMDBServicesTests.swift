//
//  MyFavouriteMoviesTests.swift
//  MyFavouriteMoviesTests
//
//  Created by Mohammed Janish on 02/07/25.
//

import Testing
@testable import MyFavouriteMovies

// MARK: - MockURLSessionDataTask (Remains the same as it's a low-level mock)


class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }

    override func cancel() {
        
    }
}

// MARK: - MockURLSession (Remains the same as it's a low-level mock)

class MockURLSession: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        super.init(configuration: .default)
    }

    override func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        guard let data = data, let response = response else {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }

    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        guard let data = data, let response = response else {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }
}


// MARK: - TMDBServiceTests (Converted to Swift Testing)

struct TMDBServiceTests {

    // MARK: - Helper for Mocking JSON Data

    private func jsonData(from string: String) -> Data? {
        return string.data(using: .utf8)
    }

    private func httpResponse(statusCode: Int) -> HTTPURLResponse? {
        return HTTPURLResponse(url: URL(string: "https://api.themoviedb.org")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }

    // MARK: - Test fetchPopularMovies

    @Test func testFetchPopularMovies_Success() async throws {
        let mockJson = """
        {
            "page": 1,
            "results": [
                {
                    "adult": false,
                    "backdrop_path": "/path1.jpg",
                    "genre_ids": [28, 878],
                    "id": 1,
                    "original_language": "en",
                    "original_title": "Movie One",
                    "overview": "Overview one.",
                    "popularity": 100.0,
                    "poster_path": "/poster1.jpg",
                    "release_date": "2023-01-01",
                    "title": "Movie One",
                    "video": false,
                    "vote_average": 7.5,
                    "vote_count": 1000
                },
                {
                    "adult": false,
                    "backdrop_path": "/path2.jpg",
                    "genre_ids": [35],
                    "id": 2,
                    "original_language": "en",
                    "original_title": "Movie Two",
                    "overview": "Overview two.",
                    "popularity": 200.0,
                    "poster_path": "/poster2.jpg",
                    "release_date": "2023-02-01",
                    "title": "Movie Two",
                    "video": false,
                    "vote_average": 8.0,
                    "vote_count": 2000
                }
            ],
            "total_pages": 10,
            "total_results": 200
        }
        """
        let mockData = jsonData(from: mockJson)
        let mockResponse = httpResponse(statusCode: 200)

        let mockSession = MockURLSession(data: mockData, response: mockResponse, error: nil)
        let testService = TMDBService(session: mockSession)

        let movies = try await testService.fetchPopularMovies()

        #expect(movies.count == 2, "Should have parsed 2 movies")
        #expect(movies[0].id == 1)
        #expect(movies[0].title == "Movie One")
        #expect(movies[1].id == 2)
        #expect(movies[1].title == "Movie Two")
    }

    @Test func testFetchPopularMovies_InvalidResponse() async throws {
        let mockData = jsonData(from: "{}")
        let mockResponse = httpResponse(statusCode: 404)
        let mockSession = MockURLSession(data: mockData, response: mockResponse, error: nil)
        let testService = TMDBService(session: mockSession)

        do {
            _ = try await testService.fetchPopularMovies()
            #expect(false, "fetchPopularMovies should have thrown an error for invalid response")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse, "Correctly caught invalid response error")
        } catch {
            #expect(false, "Caught unexpected error: \(error)")
        }
    }

    @Test func testFetchPopularMovies_DecodingError() async throws {
        let mockData = jsonData(from: "{ \"results\": [ { \"id\": \"not_an_int\" } ] }")
        let mockResponse = httpResponse(statusCode: 200)
        let mockSession = MockURLSession(data: mockData, response: mockResponse, error: nil)
        let testService = TMDBService(session: mockSession)

        do {
            _ = try await testService.fetchPopularMovies()
            #expect(false, "fetchPopularMovies should have thrown a decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                #expect(true, "Correctly caught decoding error")
            } else {
                #expect(false, "Caught wrong error type: \(error)")
            }
        } catch {
            #expect(false, "Caught unexpected error: \(error)")
        }
    }

    @Test func testFetchPopularMovies_NetworkError() async throws {
        let mockError = URLError(.notConnectedToInternet)
        let mockSession = MockURLSession(data: nil, response: nil, error: mockError)
        let testService = TMDBService(session: mockSession)

        
        do {
            _ = try await testService.fetchPopularMovies()
            #expect(false, "fetchPopularMovies should have thrown a network error")
        } catch let error as URLError {
            #expect(error.code == .notConnectedToInternet, "Correctly caught not connected to internet error")
        } catch {
            #expect(false, "Caught unexpected error: \(error)")
        }
    }

    // MARK: - Test fetchMovieDetail

    @Test func testFetchMovieDetail_Success() async throws {
        
        let mockJson = """
        {
            "adult": false,
            "backdrop_path": "/backdrop.jpg",
            "belongs_to_collection": null,
            "budget": 100000000,
            "genres": [{"id": 28, "name": "Action"}],
            "homepage": "https://example.com",
            "id": 123,
            "imdb_id": "tt1234567",
            "origin_country": ["US"],
            "original_language": "en",
            "original_title": "Detail Movie",
            "overview": "Detailed overview.",
            "popularity": 500.0,
            "poster_path": "/poster.jpg",
            "production_companies": [],
            "production_countries": [],
            "release_date": "2024-01-01",
            "revenue": 200000000,
            "runtime": 120,
            "spoken_languages": [],
            "status": "Released",
            "tagline": "A great movie.",
            "title": "Detail Movie",
            "video": false,
            "vote_average": 8.5,
            "vote_count": 5000
        }
        """
        let mockData = jsonData(from: mockJson)
        let mockResponse = httpResponse(statusCode: 200)
        let mockSession = MockURLSession(data: mockData, response: mockResponse, error: nil)
        let testService = TMDBService(session: mockSession)

        
        let movieDetail = try await testService.fetchMovieDetail(movieId: 123)

        
        #expect(movieDetail.id == 123)
        #expect(movieDetail.title == "Detail Movie")
        #expect(movieDetail.overview == "Detailed overview.")
        #expect(movieDetail.genres.first?.name == "Action")
        #expect(movieDetail.budget == 100000000)
    }

    @Test func testFetchMovieDetail_InvalidResponse() async throws {
       
        let mockData = jsonData(from: "{}")
        let mockResponse = httpResponse(statusCode: 500)
        let mockSession = MockURLSession(data: mockData, response: mockResponse, error: nil)
        let testService = TMDBService(session: mockSession)

        
        do {
            _ = try await testService.fetchMovieDetail(movieId: 123)
            #expect(false, "fetchMovieDetail should have thrown an error for invalid response")
        } catch let error as NetworkError {
            #expect(error == .invalidResponse, "Correctly caught invalid response error")
        } catch {
            #expect(false, "Caught unexpected error: \(error)")
        }
    }
}
