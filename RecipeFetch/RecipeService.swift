//
//  RecipeService.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL was invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}

protocol RecipeService {
    func fetchRecipes(from url: URL) async throws -> [Recipe]
}

private struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

struct APIClient: RecipeService {
    private let urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func fetchRecipes(from url: URL) async throws -> [Recipe] {
        guard let _ = URL(string: url.absoluteString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
            return recipeResponse.recipes
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
