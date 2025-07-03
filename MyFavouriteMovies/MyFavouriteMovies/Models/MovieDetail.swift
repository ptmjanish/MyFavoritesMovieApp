//
//  MovieDetail.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 03/07/25.
//

import Foundation

// MARK: - MovieDetail Model

struct MovieDetail: Decodable, Identifiable {
    let adult: Bool
    let backdropPath: String? // Can be null
    let belongsToCollection: CollectionInfo? // Can be null, or an object
    let budget: Int
    let genres: [Genre] // Array of objects
    let homepage: String? // Can be null
    let id: Int
    let imdbId: String? // Can be null
    let originCountry: [String] // Array of strings (e.g., ["US"])
    let originalLanguage: String
    let originalTitle: String
    let overview: String? // Can be null
    let popularity: Double
    let posterPath: String? // Can be null
    let productionCompanies: [ProductionCompany] // Array of objects
    let productionCountries: [ProductionCountry] // Array of objects
    let releaseDate: String? // Can be null
    let revenue: Int
    let runtime: Int? // Can be null
    let spokenLanguages: [SpokenLanguage] // Array of objects
    let status: String
    let tagline: String? // Can be null
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    // Use CodingKeys to map snake_case JSON keys to camelCase Swift properties
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case belongsToCollection = "belongs_to_collection"
        case budget
        case genres
        case homepage
        case id
        case imdbId = "imdb_id"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case revenue
        case runtime
        case spokenLanguages = "spoken_languages"
        case status
        case tagline
        case title
        case video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

// MARK: - Nested Models for MovieDetail

struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String
}

struct CollectionInfo: Decodable, Identifiable {
    let id: Int
    let name: String
    let posterPath: String? // Can be null
    let backdropPath: String? // Can be null

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

struct ProductionCompany: Decodable, Identifiable {
    let id: Int
    let logoPath: String? // Can be null
    let name: String
    let originCountry: String

    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

struct ProductionCountry: Decodable {
    let iso_3166_1: String
    let name: String
}

struct SpokenLanguage: Decodable {
    let englishName: String
    let iso_639_1: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso_639_1 = "iso_639_1"
        case name
    }
}
