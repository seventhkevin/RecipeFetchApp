//
//  APIClientTests.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/30/25.
//
import XCTest
@testable import RecipeFetch

final class APIClientTests: XCTestCase {
    func testFetchRecipesSuccess() async throws {
        let json = """
        {
            "recipes": [
                {
                    "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6",
                    "cuisine": "British",
                    "name": "Bakewell Tart"
                },
                {
                    "uuid": "123e4567-e89b-12d3-a456-426614174000",
                    "cuisine": "Italian",
                    "name": "Spaghetti Carbonara"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let mockSession = MockURLSession(data: json, response: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        let client = APIClient(urlSession: mockSession)
        
        let recipes = try await client.fetchRecipes(from: URL(string: "https://example.com")!)
        
        XCTAssertEqual(recipes.count, 2)
        XCTAssertEqual(recipes[0].name, "Bakewell Tart")
        XCTAssertEqual(recipes[1].name, "Spaghetti Carbonara")
    }
    
    func testFetchRecipesInvalidResponse() async {
        let mockSession = MockURLSession(data: Data(), response: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!)
        let client = APIClient(urlSession: mockSession)
        
        do {
            _ = try await client.fetchRecipes(from: URL(string: "https://example.com")!)
            XCTFail("Expected invalidResponse error")
        } catch APIError.invalidResponse {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchRecipesDecodingError() async {
        let invalidJSON = "{ \"invalid\": [] }".data(using: .utf8)!
        let mockSession = MockURLSession(data: invalidJSON, response: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        let client = APIClient(urlSession: mockSession)
        
        do {
            _ = try await client.fetchRecipes(from: URL(string: "https://example.com")!)
            XCTFail("Expected decodingError")
        } catch APIError.decodingError {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private struct MockURLSession: URLSessionProtocol, @unchecked Sendable {
    let data: Data
    let response: URLResponse
    
    init(data: Data, response: URLResponse) {
        self.data = data
        self.response = response
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        (data, response)
    }
}
