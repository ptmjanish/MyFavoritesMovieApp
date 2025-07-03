//
//  MyFavouriteMoviesUITests.swift
//  MyFavouriteMoviesUITests
//
//  Created by Mohammed Janish on 02/07/25.
//

import XCTest

final class MyFavouriteMoviesUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to make sure the application is in a clean state before runnin
        // each test.
        app = XCUIApplication()
        app.launch() // Launch the app for each test
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // Clean up any state if necessary.
    }

    // MARK: - Helper Functions

    // Helper to tap a tab bar item by its accessibility label
    @MainActor
    func tapTabBarItem(withLabel label: String) {
        let tabBar = app.tabBars.firstMatch
        let tabButton = tabBar.buttons[label]
        XCTAssertTrue(tabButton.exists, "Tab bar item '\(label)' does not exist")
        tabButton.tap()
    }

    // Helper to tap a cell in a collection view
    @MainActor
    func tapCell(inCollectionView collectionView: XCUIElement, atIndex index: Int) {
        let cell = collectionView.cells.element(boundBy: index)
        XCTAssertTrue(cell.exists, "Cell at index \(index) does not exist")
        cell.tap()
    }

    // Helper to check if a favorite button is selected
    @MainActor
    func isFavoriteButtonSelected(inCell cell: XCUIElement) -> Bool {
        // Assuming the favorite button has an accessibility identifier "FavoriteButton"
        // or its accessibility label is "Favorite"
        let favoriteButton = cell.buttons["Favorite"]
        XCTAssertTrue(favoriteButton.exists, "Favorite button does not exist in cell")
        return favoriteButton.isSelected
    }

    // MARK: - Test Cases

    @MainActor
    func testAppLaunchAndMovieListDisplay() throws {
        // Verify the main movie list is displayed on launch
        let moviesNavigationBar = app.navigationBars["Movies"] // Assuming title is "Movies"
        XCTAssertTrue(moviesNavigationBar.exists, "Movies navigation bar should exist")

        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.exists, "Collection view should exist")
        
        // Wait for cells to load (adjust timeout as needed)
        let firstCell = collectionView.cells.element(boundBy: 0)
        let exists = firstCell.waitForExistence(timeout: 10)
        XCTAssertTrue(exists, "First movie cell should appear within 10 seconds")
    }

    @MainActor
    func testFavoriteAndUnfavoriteFromMovieList() throws {
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.exists, "Collection view should exist")

        // Wait for cells to load
        let firstCell = collectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "First movie cell should appear")

        // Get the initial favorite state of the first movie
        let initialIsFavorite = isFavoriteButtonSelected(inCell: firstCell)
        
        // Tap the favorite button
        firstCell.buttons["Favorite"].tap()
        
        // Verify the state has toggled
        XCTAssertEqual(isFavoriteButtonSelected(inCell: firstCell), !initialIsFavorite, "Favorite state should toggle after tap")

        // Tap again to revert (unfavorite)
        firstCell.buttons["Favorite"].tap()
        XCTAssertEqual(isFavoriteButtonSelected(inCell: firstCell), initialIsFavorite, "Favorite state should revert after second tap")
    }

    @MainActor
    func testNavigationToFavoritesTabAndDisplay() throws {
        // Navigate to Favorites tab
        tapTabBarItem(withLabel: "Favorites") // Assuming "Favorites" is the accessibility label for the tab

        let favoritesNavigationBar = app.navigationBars["Favorites"] // Assuming title is "Favorites"
        XCTAssertTrue(favoritesNavigationBar.exists, "Favorites navigation bar should exist")

        let favoritesCollectionView = app.collectionViews.firstMatch
        XCTAssertTrue(favoritesCollectionView.exists, "Favorites collection view should exist")
        
        // If you just favorited a movie in a previous test, it should appear here.
        // This test assumes a clean state or that you'll favorite one first.
        // For robust testing, you might favorite a known movie before this test.
    }

    @MainActor
    func testFavoriteMovieAppearsInFavoritesTab() throws {
        // 1. Go to Movies tab and favorite a movie
        tapTabBarItem(withLabel: "Movies")
        let moviesCollectionView = app.collectionViews.firstMatch
        XCTAssertTrue(moviesCollectionView.waitForExistence(timeout: 5), "Movies collection view should exist")
        
        let firstMovieCell = moviesCollectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstMovieCell.waitForExistence(timeout: 10), "First movie cell should appear")
        
        let initialIsFavorite = isFavoriteButtonSelected(inCell: firstMovieCell)
        if initialIsFavorite {
            // If already favorited, unfavorite it first to ensure a clean state for testing add
            firstMovieCell.buttons["Favorite"].tap()
            XCTAssertFalse(isFavoriteButtonSelected(inCell: firstMovieCell), "Should be unfavorited")
        }
        
        // Favorite the first movie
        firstMovieCell.buttons["Favorite"].tap()
        XCTAssertTrue(isFavoriteButtonSelected(inCell: firstMovieCell), "Movie should now be favorited")

        // 2. Navigate to Favorites tab
        tapTabBarItem(withLabel: "Favorites")
        
        let favoritesCollectionView = app.collectionViews.firstMatch
        XCTAssertTrue(favoritesCollectionView.waitForExistence(timeout: 5), "Favorites collection view should exist")

        // Verify the favorited movie appears in the Favorites list
        // This assumes the first movie in the main list will be the first in favorites
        // (or you can search for its title if your FavoritesVC has search)
        let favoritedMovieCell = favoritesCollectionView.cells.element(boundBy: 0)
        XCTAssertTrue(favoritedMovieCell.waitForExistence(timeout: 5), "Favorited movie should appear in favorites list")
        
        // You can add more specific assertions here, e.g., check the title of the cell
        // let favoritedMovieTitle = favoritedMovieCell.staticTexts["Movie One"].exists // Assuming title is "Movie One"
        // XCTAssertTrue(favoritedMovieTitle, "Favorited movie title should match")
    }

    @MainActor
    func testUnfavoriteFromFavoritesTab() throws {
        // Ensure there's at least one favorite movie
        try testFavoriteMovieAppearsInFavoritesTab() // This will favorite the first movie and navigate

        let favoritesCollectionView = app.collectionViews.firstMatch
        XCTAssertTrue(favoritesCollectionView.exists, "Favorites collection view should exist")

        let firstFavoriteCell = favoritesCollectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstFavoriteCell.waitForExistence(timeout: 5), "First favorite movie cell should exist")

        // Unfavorite the first movie in the favorites list
        firstFavoriteCell.buttons["Favorite"].tap()

        // Verify it disappears from the favorites list
        let doesNotExist = firstFavoriteCell.waitForExistence(timeout: 5) // Wait for it to disappear
        XCTAssertTrue(doesNotExist, "Favorited movie should disappear from favorites list")
    }

    @MainActor
    func testNavigationToMovieDetailView() throws {
        // Navigate to Movies tab
        tapTabBarItem(withLabel: "Movies")
        
        let moviesCollectionView = app.collectionViews.firstMatch
        XCTAssertTrue(moviesCollectionView.waitForExistence(timeout: 5), "Movies collection view should exist")
        
        let firstMovieCell = moviesCollectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstMovieCell.waitForExistence(timeout: 10), "First movie cell should appear")
        
        // Tap on the first movie cell to go to details
        firstMovieCell.tap()

        // Verify the Movie Detail View appears
        let movieDetailNavigationBar = app.navigationBars.firstMatch // Assuming the detail view has a navigation bar
        XCTAssertTrue(movieDetailNavigationBar.waitForExistence(timeout: 5), "Movie Detail navigation bar should exist")
        
        // You can assert specific labels or content on the detail view
        // For example, if you have a title label with accessibility identifier:
        // let detailTitle = app.staticTexts["Movie Title Label"].exists
        // XCTAssertTrue(detailTitle, "Movie title label should be present on detail view")
        
        // Go back to the list view
        app.navigationBars.buttons.element(boundBy: 0).tap() // Tap the back button
        XCTAssertTrue(moviesCollectionView.waitForExistence(timeout: 5), "Should navigate back to movie list")
    }
}
