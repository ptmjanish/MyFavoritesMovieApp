//
//  RealmManager.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 02/07/25.
//

import Foundation

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    private var realm: Realm!

    private init() {
        do {
            realm = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
            fatalError("Failed to initialize Realm database.") // Fatal error for critical setup failure
        }
    }

    // MARK: - CRUD Operations

    func addFavorite(movie: Movie) {
        let favoriteMovie = FavoriteMovie(movie: movie)
        do {
            try realm.write {
                realm.add(favoriteMovie, update: .modified) // Use .modified to update if primary key exists
            }
        } catch {
            print("Error adding favorite movie: \(error)")
        }
    }

    func removeFavorite(movieId: Int) {
        if let favoriteMovie = realm.object(ofType: FavoriteMovie.self, forPrimaryKey: movieId) {
            do {
                try realm.write {
                    realm.delete(favoriteMovie)
                }
            } catch {
                print("Error removing favorite movie: \(error)")
            }
        }
    }

    func getAllFavorites() -> Results<FavoriteMovie> {
        return realm.objects(FavoriteMovie.self).sorted(byKeyPath: "title", ascending: true)
    }

    func isFavorite(movieId: Int) -> Bool {
        return realm.object(ofType: FavoriteMovie.self, forPrimaryKey: movieId) != nil
    }
}
