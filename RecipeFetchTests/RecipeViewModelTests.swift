//
//  RecipeViewModelTests.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/30/25.
//
import XCTest
@testable import RecipeFetch
import UIKit

final class RecipeViewModelTests: XCTestCase {
    var viewModel: RecipeViewModel!
    var mockRecipeService: MockRecipeService!
    
    override func setUp() {
        super.setUp()
        mockRecipeService = MockRecipeService()
        viewModel = RecipeViewModel(apiClient: mockRecipeService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRecipeService = nil
        super.tearDown()
    }
    
    func testFetchRecipesSuccess() async throws {
        let url = URL(string: "https://example.com/recipes")!
        let recipes = [
            Recipe(
                id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
                cuisine: "Italian",
                name: "Pizza",
                photoURLLarge: nil,
                photoURLSmall: URL(string: "https://example.com/pizza.jpg"),
                sourceURL: nil,
                youtubeURL: nil
            ),
            Recipe(
                id: UUID(uuidString: "223e4567-e89b-12d3-a456-426614174001")!,
                cuisine: "Mexican",
                name: "Tacos",
                photoURLLarge: nil,
                photoURLSmall: nil,
                sourceURL: nil,
                youtubeURL: nil
            )
        ]
        mockRecipeService.mockRecipes = recipes
        
        await viewModel.fetchRecipes(from: url)
        
        switch viewModel.state {
        case .loaded(let loadedRecipes):
            XCTAssertEqual(loadedRecipes, recipes.sorted { $0.name.lowercased() < $1.name.lowercased() }, "Recipes should be sorted by name by default")
        default:
            XCTFail("Expected loaded state")
        }
    }
    
    func testFetchRecipesError() async throws {
        let url = URL(string: "https://example.com/recipes")!
        mockRecipeService.shouldThrowError = true
        
        await viewModel.fetchRecipes(from: url)
        
        switch viewModel.state {
        case .error:
            break
        default:
            XCTFail("Expected error state")
        }
    }
    
    func testCacheImageInvalidData() async throws {
        let url = URL(string: "https://example.com/invalid.jpg")!
        let mockSession = MockURLSession(data: Data(), response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/jpeg"])!)
        let mockFileManager = MockFileManager()
        let mockCache = ImageCache(fileManager: mockFileManager, urlSession: mockSession)
        
        do {
            try await viewModel.cacheImage(from: url)
            XCTFail("Expected error for invalid image data")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "RecipeViewModel", "Error domain should be RecipeViewModel")
            XCTAssertEqual(error.code, -1, "Error code should be -1")
            XCTAssertTrue(mockFileManager.files.isEmpty, "No data should be cached")
        }
    }
    
    func testSortByName() async throws {
        let recipes = [
            Recipe(
                id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
                cuisine: "Italian",
                name: "Ziti",
                photoURLLarge: nil,
                photoURLSmall: nil,
                sourceURL: nil,
                youtubeURL: nil
            ),
            Recipe(
                id: UUID(uuidString: "223e4567-e89b-12d3-a456-426614174001")!,
                cuisine: "Mexican",
                name: "Tacos",
                photoURLLarge: nil,
                photoURLSmall: nil,
                sourceURL: nil,
                youtubeURL: nil
            ),
            Recipe(
                id: UUID(uuidString: "323e4567-e89b-12d3-a456-426614174002")!,
                cuisine: "Indian",
                name: "Curry",
                photoURLLarge: nil,
                photoURLSmall: nil,
                sourceURL: nil,
                youtubeURL: nil
            )
        ]
        viewModel.state = .loaded(recipes)
        viewModel.sortOption = .name // Triggers didSet
        
        switch viewModel.state {
        case .loaded(let sortedRecipes):
            let expected = recipes.sorted { $0.name.lowercased() < $1.name.lowercased() }
            XCTAssertEqual(sortedRecipes, expected, "Recipes should be sorted by name")
            XCTAssertEqual(sortedRecipes.map { $0.name }, ["Curry", "Tacos", "Ziti"], "Names should be in alphabetical order")
        default:
            XCTFail("Expected loaded state")
        }
    }
    
    func testSortByCuisine() async throws {
        let recipes = [
            Recipe(
                id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
                cuisine: "Italian",
                name: "Ziti",
                photoURLLarge: nil,
                photoURLSmall: nil,
                sourceURL: nil,
                youtubeURL: nil
            ),
            Recipe(
                id: UUID(uuidString: "223e4567-e89b-12d3-a456-426614174001")!,
                cuisine: "Mexican",
                name: "Tacos",
                photoURLLarge: nil,
                photoURLSmall: nil,
                sourceURL: nil,
                youtubeURL: nil
            ),
            Recipe(
                id: UUID(uuidString: "323e4567-e89b-12d3-a456-426614174002")!,
                cuisine: "Indian",
                name: "Curry",
                photoURLLarge: nil,
                photoURLSmall: nil,
                sourceURL: nil,
                youtubeURL: nil
            )
        ]
        viewModel.state = .loaded(recipes)
        viewModel.sortOption = .cuisine // Triggers didSet
        
        switch viewModel.state {
        case .loaded(let sortedRecipes):
            let expected = recipes.sorted { $0.cuisine.lowercased() < $1.cuisine.lowercased() }
            XCTAssertEqual(sortedRecipes, expected, "Recipes should be sorted by cuisine")
            XCTAssertEqual(sortedRecipes.map { $0.cuisine }, ["Indian", "Italian", "Mexican"], "Cuisines should be in alphabetical order")
        default:
            XCTFail("Expected loaded state")
        }
    }
}

class MockRecipeService: RecipeService {
    var mockRecipes: [Recipe] = []
    var shouldThrowError = false
    
    func fetchRecipes(from url: URL) async throws -> [Recipe] {
        if shouldThrowError {
            throw NSError(domain: "MockRecipeService", code: -1, userInfo: nil)
        }
        return mockRecipes
    }
}
