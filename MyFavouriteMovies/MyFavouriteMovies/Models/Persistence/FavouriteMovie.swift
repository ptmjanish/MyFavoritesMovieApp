//
//  FavouriteMovie.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 02/07/25.
//

import Foundation


import Foundation
import RealmSwift


class FavoriteMovie: Object {
    @Persisted(primaryKey: true) var id: Int

    @Persisted var title: String
    @Persisted var overview: String
    @Persisted var posterPath: String?
    @Persisted var backdropPath: String?
    @Persisted var voteAverage: Double
    @Persisted var releaseDate: String?
    @Persisted var genreIds: RealmSwift.List<Int>
    @Persisted var adult: Bool
    @Persisted var originalLanguage: String
    @Persisted var originalTitle: String
    @Persisted var popularity: Double
    @Persisted var video: Bool
    @Persisted var voteCount: Int

    // Convenience initializer to easily create a FavoriteMovie from a Movie struct
    convenience init(movie: Movie) {
        self.init() 
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.posterPath
        self.backdropPath = movie.backdropPath
        self.voteAverage = movie.voteAverage
        self.releaseDate = movie.releaseDate
        self.adult = movie.adult
        self.originalLanguage = movie.originalLanguage
        self.originalTitle = movie.originalTitle
        self.popularity = movie.popularity
        self.video = movie.video
        self.voteCount = movie.voteCount
        self.genreIds = RealmSwift.List<Int>()
        if let movieGenreIds = movie.genreIds {
            self.genreIds.append(objectsIn: movieGenreIds)
        }
        
        
    }
}
