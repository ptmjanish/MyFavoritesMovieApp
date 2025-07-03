//
//  MovieDetailView.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 03/07/25.
//

import SwiftUI
import RealmSwift

struct MovieDetailView: View {
    let basicMovie: Movie

    @State private var movieDetail: MovieDetail? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var isFavorite: Bool

    // Base URL for TMDB images
    private let imageBaseUrl = "https://image.tmdb.org/t/p/"

    // MARK: - Initialization
    init(basicMovie: Movie) {
        self.basicMovie = basicMovie
        _isFavorite = State(initialValue: RealmManager.shared.isFavorite(movieId: basicMovie.id))
    }

    // MARK: - View Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if isLoading {
                    // MARK: Loading State UI
                    ProgressView("Loading Movie Details...")
                        .font(.title2)
                        .padding()
                    Spacer()
                } else if let errorMessage = errorMessage {
                    // MARK: Error State UI
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await fetchMovieDetail()
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else if let movie = movieDetail {
                    // MARK: Content Display State UI
                    
                    // Backdrop Image Section
                    backdropImageSection(for: movie)

                    // Header Section (Poster, Title, Rating, Favorite Button)
                    headerSection(for: movie)
                    
                    // Tagline
                    if let tagline = movie.tagline, !tagline.isEmpty {
                        Text(tagline)
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 40)
                    }

                    // Overview
                    Text("Overview")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal, 40)
                    Text(movie.overview ?? "No overview available.")
                        .font(.body)
                        .padding(.horizontal, 40)
                        .fixedSize(horizontal: false, vertical: true)

                    // Metadata Section
                    metadataSection(for: movie)
                    
                    Spacer()
                }
            }
        }
        .task {
            await fetchMovieDetail()
        }
        .navigationTitle(movieDetail?.title ?? basicMovie.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.isFavorite = RealmManager.shared.isFavorite(movieId: basicMovie.id)
        }
    }

    // MARK: - Subviews/Sections (now taking 'movie' as a parameter)

    private func backdropImageSection(for movie: MovieDetail) -> some View {
        AsyncImage(url: URL(string: imageBaseUrl + "w780" + (movie.backdropPath ?? ""))) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if phase.error != nil {
                Color.gray.opacity(0.3)
                    .overlay(Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(.gray))
            } else {
                ProgressView()
            }
        }
        .frame(height: 250)
        .clipped()
        .overlay(
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)
        )
    }

    private func headerSection(for movie: MovieDetail) -> some View {
        HStack(alignment: .top, spacing: 15) {
            // Poster Image
            AsyncImage(url: URL(string: imageBaseUrl + "w500" + (movie.posterPath ?? ""))) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Image(systemName: "film.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .padding(20)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 120, height: 180)
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.leading, 15)
            .offset(y: -50)

            VStack(alignment: .leading, spacing: 5) {
                Text(movie.title)
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.title3)
                    Text("(\(movie.voteCount) votes)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Favorite Button
                Button {
                    toggleFavorite()
                } label: {
                    Label("Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.title2)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Capsule().stroke(Color.red, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, -30)
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    private func metadataSection(for movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Release Date: \(formattedReleaseDate(for: movie))")
            Text("Runtime: \(formattedRuntime(for: movie))")
            Text("Genres: \(formattedGenres(for: movie))")
            
            if movie.budget > 0 {
                Text("Budget: \(formattedBudget(for: movie))")
            }
            if movie.revenue > 0 {
                Text("Revenue: \(formattedRevenue(for: movie))")
            }
            Text("Status: \(movie.status)")
            
            if let homepage = movie.homepage, !homepage.isEmpty, let url = URL(string: homepage) {
                Link("Homepage", destination: url)
                    .font(.body)
            }
        }
        .font(.body)
        .padding(.horizontal, 40)
        .padding(.top, 10)
    }

    // MARK: - Helper Functions for Formatting Data (now taking 'movie' as parameter)

    private func formattedReleaseDate(for movie: MovieDetail) -> String {
        guard let dateString = movie.releaseDate, !dateString.isEmpty else { return "N/A" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return "N/A"
    }

    private func formattedRuntime(for movie: MovieDetail) -> String {
        if let runtime = movie.runtime, runtime > 0 {
            return "\(runtime) min"
        }
        return "N/A"
    }

    private func formattedGenres(for movie: MovieDetail) -> String {
        if !movie.genres.isEmpty {
            return movie.genres.map { $0.name }.joined(separator: ", ")
        }
        return "N/A"
    }
    
    private func formattedBudget(for movie: MovieDetail) -> String {
        guard movie.budget > 0 else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: movie.budget)) ?? "N/A"
    }

    private func formattedRevenue(for movie: MovieDetail) -> String {
        guard movie.revenue > 0 else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: movie.revenue)) ?? "N/A"
    }

    // MARK: - Favorite Logic

    private func toggleFavorite() {
        guard let movie = movieDetail else { return }
        
        let movieForRealm = Movie(movieDetail: movie)

        if isFavorite {
            RealmManager.shared.removeFavorite(movieId: movieForRealm.id)
            print("Unfavorited: \(movieForRealm.title)")
        } else {
            RealmManager.shared.addFavorite(movie: movieForRealm)
            print("Favorited: \(movieForRealm.title)")
        }
        isFavorite.toggle()
    }
    
    // MARK: - Data Fetching
    private func fetchMovieDetail() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedDetail = try await TMDBService.shared.getDetails(of: basicMovie)
            self.movieDetail = fetchedDetail
            self.isFavorite = RealmManager.shared.isFavorite(movieId: fetchedDetail.id)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Failed to fetch movie detail for ID \(basicMovie.id): \(error.localizedDescription)")
        }
    }
}


// MARK: - Preview Provider (for Xcode Canvas)

//struct MovieDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create a dummy 'Movie' (from your list) for the preview
//        // This is the minimum info passed from the list view
//        let dummyBasicMovie = Movie(
//            id: 986056,
//            title: "Thunderbolts*",
//            overview: "A brief overview...",
//            posterPath: "/hBH50Mkcrc4m8x73CovLmY7vBx1.jpg",
//            backdropPath: "/rthMuZfFv4fqEU4JVbgSW9wQ8rs.jpg",
//            voteAverage: 7.46,
//            releaseDate: "2025-04-30",
//            genreIds: List<Int>([28, 878, 12]), // Example for Realm List
//            adult: false,
//            originalLanguage: "en",
//            originalTitle: "Thunderbolts*",
//            popularity: 631.3592,
//            video: false,
//            voteCount: 1354
//        )
//        
//        NavigationView { // Embed in NavigationView for title and back button
//            MovieDetailView(basicMovie: dummyBasicMovie)
//        }
//    }
//}
