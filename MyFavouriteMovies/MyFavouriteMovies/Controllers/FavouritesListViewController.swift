//
//  FavouritesListViewController.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 02/07/25.
//

import UIKit
import RealmSwift
import SwiftUI

class FavouritesListViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getFavouriteMovies()
    }
    var movies: Results<FavoriteMovie>?
    var filteredMovies: [FavoriteMovie] = [] // For search results
    var isSearching: Bool = false
    let realmManager = RealmManager.shared
    
    func registerCells() {
        moviesCollectionView.register(UINib(nibName: "MovieListCell", bundle: nil), forCellWithReuseIdentifier: "MovieListCell")
    }
    
    private func getFavouriteMovies() {
        movies = realmManager.getAllFavorites()
        if let favorites = movies {
            filteredMovies = favorites.compactMap({$0})
        }
        moviesCollectionView.reloadData()
    }

    private func applyFilter(for searchText: String) {
        guard let allFavorites = movies else {
            filteredMovies = []
            moviesCollectionView.reloadData()
            return
        }
        if !searchText.isEmpty {
            let filteredResults = allFavorites.filter("title CONTAINS[c] %@ OR overview CONTAINS[c] %@", searchText, searchText)
            
            filteredMovies = filteredResults.compactMap({$0})
        }
        moviesCollectionView.reloadData()
    }
    
    private func showDetails(for movie: FavoriteMovie) {
        let movie = Movie(favoriteMovie: movie)
        let movieDetailSwiftUIView = MovieDetailView(basicMovie: movie)
        let hostingController = UIHostingController(rootView: movieDetailSwiftUIView)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }

}

extension FavouritesListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieListCell", for: indexPath) as! MovieListCell
        let list = filteredMovies
        let currentMovie = Movie(favoriteMovie: list[indexPath.item])
        cell.configure(with: currentMovie, isFavorite: true)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsPerRow: CGFloat = 4 // Desired number of cells per row
        
        // Define the spacing you want
        let minimumInteritemSpacing: CGFloat = 8 // Spacing between items in the same row
        let sectionInsetLeft: CGFloat = 8 // Left padding for the section
        let sectionInsetRight: CGFloat = 8 // Right padding for the section
        let totalHorizontalSpacing = (numberOfCellsPerRow - 1) * minimumInteritemSpacing + sectionInsetLeft + sectionInsetRight
        let width = (collectionView.bounds.width - totalHorizontalSpacing) / numberOfCellsPerRow
        let height = width * 1.5 // Adjust this multiplier based on your desired cell aspect ratio
        
        return CGSize(width: width, height: height)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) // Matches values used in sizeForItemAt
    }
}

extension FavouritesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showDetails(for: filteredMovies[indexPath.item])
    }
}


extension FavouritesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.applyFilter(for: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = true
        self.applyFilter(for: searchBar.text ?? "")
    }
}

extension FavouritesListViewController: MovieListCellDelegate {
    func movieListCell(_ cell: MovieListCell, didToggleFavorite movie: Movie, isFavorite: Bool) {
        if isFavorite {
            RealmManager.shared.addFavorite(movie: movie)
        }
        else {
            RealmManager.shared.removeFavorite(movieId: movie.id)
        }
        self.getFavouriteMovies()
    }
}
