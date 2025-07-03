# **My Favourite Movies App**

A modern iOS application for browsing popular movies, viewing detailed information, and managing a list of favorite films.

## **Table of Contents**

* [Features](https://www.google.com/search?q=%23features)  
* [Technologies Used](https://www.google.com/search?q=%23technologies-used)  
* [Setup and Installation](https://www.google.com/search?q=%23setup-and-installation)  
* [Usage](https://www.google.com/search?q=%23usage)  
* [Testing](https://www.google.com/search?q=%23testing)  
* [Future Enhancements](https://www.google.com/search?q=%23future-enhancements)  
* [Credits](https://www.google.com/search?q=%23credits)

## **Features**

* **Browse Popular Movies:** View a dynamically loaded list of popular movies from The Movie Database (TMDb) API.  
* **Movie Details:** Tap on any movie to view comprehensive details including overview, release date, runtime, genres, cast (placeholder for future), and more.  
* **Favorite Movies:** Mark movies as favorites and manage them in a dedicated "Favorites" tab.  
* **Offline Favorites:** Favorite movies are persisted locally using Realm, allowing users to view their favorite list even without an internet connection.  
* **Search Favorites:** Search through your favorite movies by title or overview.  
* **Responsive UI:** The application layout adapts to various iOS device sizes and orientations.  
* **Smooth Image Loading:** Asynchronous image loading for movie posters and backdrops ensures a fluid user experience.  
* **Loading Indicators:** Provides clear visual feedback during data fetching.  
* **Robust Error Handling:** Gracefully handles API failures with dummy data fallback and user-friendly alerts.

## **Technologies Used**

* **Swift:** The primary programming language.  
* **UIKit:** For the main list and favorites view controllers (UICollectionView, UIViewController).  
* **SwiftUI:** For the detailed movie view (MovieDetailView), demonstrating modern declarative UI.  
* **async/await (Swift Concurrency):** For efficient asynchronous operations, especially network requests and image loading.  
* **RealmSwift:** For local data persistence (storing favorite movies).  
* **URLSession:** For all network communication with TMDb API.  
* **JSONDecoder:** For parsing JSON responses into Swift models.  
* **XCTest:** For UI Testing.  
* **Swift Testing Framework:** For Unit Testing the networking layer.

## **Setup and Installation**

To get a copy of the project up and running on your local machine for development and testing purposes, follow these steps.

### **Prerequisites**

* Xcode 15.0 or later  
* iOS 17.0 SDK or later

### **Installation Steps**

1. **Clone the repository:**  
   git clone \<repository\_url\_here\>  
   cd MyFavouriteMovies

2. Open in Xcode:  
   Open the MyFavouriteMovies.xcodeproj file in Xcode.  
3. **Get a TMDb API Key:**  
   * Go to [The Movie Database (TMDb) website](https://www.themoviedb.org/).  
   * Sign up for an account.  
   * Navigate to your account settings and request an API key (v3 API).  
4. **Insert API Key:**  
   * Open TMDBService.swift.  
   * Locate the line: private let apiKey \= "YOUR\_API\_KEY\_HERE"  
   * Replace "YOUR\_API\_KEY\_HERE" with your actual TMDb API key.  
5. **Build and Run:**  
   * Select the MyFavouriteMovies scheme.  
   * Choose a simulator or connect an iOS device.  
   * Click the "Run" button (Cmd \+ R).

## **Usage**

* **Movies Tab:** Displays a grid of popular movies. Scroll to load more.  
* **Favorite Button:** Tap the heart icon on any movie cell to add/remove it from your favorites. The button will change its appearance to reflect the favorite status.  
* **Movie Details:** Tap anywhere on a movie cell (excluding the favorite button) to navigate to its detail screen.  
* **Favorites Tab:** View all your favorited movies. You can also unfavorite movies from this list.  
* **Search (Favorites Tab):** Use the search bar in the Favorites tab to filter your favorite movies.

## **Testing**

The project includes both Unit Tests for the networking layer and UI Tests for the main user flows.

### **Running Unit Tests**

1. Select the MyFavouriteMoviesTests scheme in Xcode.  
2. Go to Product \> Test (or press Cmd \+ U).  
3. The tests for TMDBService (parsing, error handling with mocked URLSession) will run.

### **Running UI Tests**

1. Select the MyFavouriteMoviesUITests scheme in Xcode.  
2. Go to Product \> Test (or press Cmd \+ U).  
3. The app will launch on a simulator, and automated interactions will simulate user behavior to verify navigation, favoriting, and unfavoriting flows.

## **Future Enhancements**

* **Pagination:** Implement infinite scrolling for the main movie list.  
* **Caching:** Implement more robust image and API response caching.  
* **Search Functionality:** Add search to the main movie list.  
* **Movie Trailers:** Integrate video playback for trailers.  
* **Cast & Crew Details:** Display information about the cast and crew.  
* **User Authentication:** Allow users to log in and sync favorites across devices.  
* **More Details:** Display additional fields from the MovieDetail model (e.g., production companies, spoken languages).  
* **Improved UI/UX:** Refine animations, transitions, and overall visual design.

## **Credits**

* **The Movie Database (TMDb):** For providing the movie data API.  
* **Realm:** For the local persistence solution.  
* **SF Symbols:** For system icons.