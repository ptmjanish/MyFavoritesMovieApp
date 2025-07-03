//
//  MovieListViewController.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 02/07/25.
//

import UIKit
import SwiftUI

class MovieListViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moviesCollectionView: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        Task {
            await fetchPopularMovies()
        }
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func registerCells() {
        moviesCollectionView.register(UINib(nibName: "MovieListCell", bundle: nil), forCellWithReuseIdentifier: "MovieListCell")
        
    }
    
    var movies: [Movie] = []
    var filteredMovies: [Movie] = [] // For search results
    var isSearching: Bool = false
    let realmManager = RealmManager.shared
    
    
    //MARK: API Calls
    @MainActor // Ensures UI updates happen on the main thread automatically
        private func fetchPopularMovies() async {
            
            DispatchQueue.main.async {
                self.showLoadingIndicator()
            }

            do {
                let fetchedMovies = try await TMDBService.shared.fetchPopularMovies()
                self.movies = fetchedMovies
                self.moviesCollectionView.reloadData()
                
                print("Successfully fetched \(fetchedMovies.count) popular movies.")
            } catch {
                print("Error fetching popular movies: \(error.localizedDescription)")
                showErrorAlert(message: error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
            }
        }
    
    @MainActor
    func searchMovieswith(query: String) {
        
        Task {
            DispatchQueue.main.async {
                self.showLoadingIndicator()
            }
            do {
                let searchedMovies = try await TMDBService.shared.searchMovies(query: query)
                self.filteredMovies = searchedMovies
                self.moviesCollectionView.reloadData()
                print("Successfully fetched \(searchedMovies.count) popular movies.")
            }
            catch {
                print("Error fetching popular movies: \(error.localizedDescription)")
                showErrorAlert(message: error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showDetails(for movie: Movie) {
        let movieDetailSwiftUIView = MovieDetailView(basicMovie: movie)
        let hostingController = UIHostingController(rootView: movieDetailSwiftUIView)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }

}

extension MovieListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredMovies.count : movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieListCell", for: indexPath) as! MovieListCell
        let list = isSearching ? filteredMovies : movies
        let currentMovie = list[indexPath.item]
        let isFavorite = realmManager.isFavorite(movieId: currentMovie.id)
        cell.configure(with: currentMovie, isFavorite: isFavorite)
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

extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = isSearching ? filteredMovies : movies
        let currentMovie = list[indexPath.item]
        self.showDetails(for: currentMovie)
    }
}


extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchMovieswith(query: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
}

extension MovieListViewController: MovieListCellDelegate {
    func movieListCell(_ cell: MovieListCell, didToggleFavorite movie: Movie, isFavorite: Bool) {
        if isFavorite {
            RealmManager.shared.addFavorite(movie: movie)
        }
        else {
            RealmManager.shared.removeFavorite(movieId: movie.id)
        }
        let listedMovies = isSearching ? filteredMovies : movies
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            var movieToUpdate = listedMovies[index]
            movieToUpdate.isFavorite = isFavorite
            if isSearching {
                filteredMovies[index] = movieToUpdate
            }
            else {
                movies[index] = movieToUpdate
            }
            
            let indexPathToLoad = IndexPath(item: index, section: 0)
            moviesCollectionView.reloadItems(at: [indexPathToLoad])
        }
    }
}
