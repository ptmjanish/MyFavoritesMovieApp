//
//  MockURLSession.swift
//  MyFavouriteMoviesTests
//
//  Created by Mohammed Janish on 03/07/25.
//
import Testing
@testable import MyFavouriteMovies
import Foundation

// MARK: - MockURLSessionDataTask

// A mock for URLSessionDataTask to prevent actual network calls
class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    // Override resume to execute the closure immediately, simulating task completion
    override func resume() {
        closure()
    }

    // Override cancel if you need to test cancellation logic, otherwise a no-op is fine
    override func cancel() {
        // No-op for this simple mock
    }
}

// MARK: - MockURLSession

// A mock for URLSession to control the data, response, and error returned
class MockURLSession: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    // Custom initializer to set the mock data, response, and error
    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
        // Call super.init() for URLSession
        super.init(configuration: .default) // Needs a configuration, but it's not used by our mock
    }

    // Override data(from:) to return our predefined mock data
    override func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        guard let data = data, let response = response else {
            // If data or response are missing, simulate a network error
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }

    // Override data(for:) if your service uses URLRequest instead of URL directly
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
