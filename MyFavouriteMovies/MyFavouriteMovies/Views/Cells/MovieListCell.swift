//
//  MovieListCell.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 02/07/25.
//

import UIKit

protocol MovieListCellDelegate: AnyObject {
    func movieListCell(_ cell: MovieListCell, didToggleFavorite movie: Movie, isFavorite: Bool)
}

class MovieListCell: UICollectionViewCell {
    
    var movie: Movie?
    
    weak var delegate: MovieListCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movie = nil
        btnFavourite.isSelected = false
    }

    func configure(with movie: Movie, isFavorite: Bool) {
        self.movie = movie
        btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
        btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        
        labelTitle.text = movie.title
        
        if movie.voteAverage > 0 {
            labelRating.text = String(format: "%.1f", movie.voteAverage)
        } else {
            labelRating.text = "N/A"
        }
        
        btnFavourite.isSelected = isFavorite
        
        if let posterPath = movie.posterPath {
            let baseUrl = "https://image.tmdb.org/t/p/w500" // Base URL for TMDB images
            guard let imageUrl = URL(string: baseUrl + posterPath) else {
                movieImage.image = UIImage(systemName: "exclamationmark.triangle.fill")
                movieImage.tintColor = .systemRed
                print("Error: Invalid image URL for posterPath: \(posterPath)")
                return
            }
            
            movieImage.image = UIImage(systemName: "photo.fill")
            movieImage.tintColor = .systemGray
            
            let imageTargetPosterPath = movie.posterPath
            
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: imageUrl)
                    
                    if self.movie?.posterPath == imageTargetPosterPath {
                        self.movieImage.image = UIImage(data: data)
                    } else {
                        print("Cell reused for a different movie, ignoring image for: \(posterPath)")
                    }
                } catch {
                    print("Error loading image for movie \(movie.title) (\(posterPath)): \(error.localizedDescription)")
                    if self.movie?.posterPath == imageTargetPosterPath {
                        self.movieImage.image = UIImage(systemName: "exclamationmark.icloud.fill")
                        self.movieImage.tintColor = .systemRed
                    }
                }
            }
        } else {
            movieImage.image = UIImage(systemName: "film.fill")
            movieImage.tintColor = .lightGray
        }
    }
   

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelRating: UILabel!
    @IBOutlet weak var btnFavourite: UIButton!
    
    @IBAction func btnFavouriteTapped(_ sender: UIButton) {
        if let movie = movie {
            self.movie!.isFavorite = !movie.isFavorite
            sender.isSelected = self.movie!.isFavorite
            delegate?.movieListCell(self, didToggleFavorite: movie, isFavorite: sender.isSelected)
        }
        
    }
    
    
    
}
