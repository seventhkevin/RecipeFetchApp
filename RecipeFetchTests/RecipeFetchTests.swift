//
//  RecipeFetchTests.swift
//  RecipeFetchTests
//
//  Created by Kevin Hewitt on 5/29/25.
//

import XCTest
@testable import RecipeFetch

final class RecipeTests: XCTestCase {
    func testDecodeRecipeWithAllFields() throws {
        let json = """
        {
            "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6",
            "cuisine": "British",
            "name": "Bakewell Tart",
            "photo_url_large": "https://some.url/large.jpg",
            "photo_url_small": "https://some.url/small.jpg",
            "source_url": "https://some.url/index.html",
            "youtube_url": "https://www.youtube.com/watch?v=some.id"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let recipe = try decoder.decode(Recipe.self, from: json)
        
        XCTAssertEqual(recipe.id.uuidString, "EED6005F-F8C8-451F-98D0-4088E2B40EB6")
        XCTAssertEqual(recipe.cuisine, "British")
        XCTAssertEqual(recipe.name, "Bakewell Tart")
        XCTAssertEqual(recipe.photoURLLarge?.absoluteString, "https://some.url/large.jpg")
        XCTAssertEqual(recipe.photoURLSmall?.absoluteString, "https://some.url/small.jpg")
        XCTAssertEqual(recipe.sourceURL?.absoluteString, "https://some.url/index.html")
        XCTAssertEqual(recipe.youtubeURL?.absoluteString, "https://www.youtube.com/watch?v=some.id")
    }
    
    func testDecodeRecipeWithMissingFields() throws {
        let json = """
        {
            "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6",
            "cuisine": "British",
            "name": "Bakewell Tart"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let recipe = try decoder.decode(Recipe.self, from: json)
        
        XCTAssertEqual(recipe.id.uuidString, "EED6005F-F8C8-451F-98D0-4088E2B40EB6")
        XCTAssertEqual(recipe.cuisine, "British")
        XCTAssertEqual(recipe.name, "Bakewell Tart")
        XCTAssertNil(recipe.photoURLLarge)
        XCTAssertNil(recipe.photoURLSmall)
        XCTAssertNil(recipe.sourceURL)
        XCTAssertNil(recipe.youtubeURL)
    }
    
    func testDecodeInvalidUUID() {
        let json = """
        {
            "uuid": "invalid-uuid",
            "cuisine": "British",
            "name": "Bakewell Tart"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(Recipe.self, from: json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}
