//
//  RecipeViewModel.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
import SwiftUI

class RecipeViewModel: ObservableObject {
    enum State {
        case loading
        case loaded([Recipe])
        case error(Error)
    }

    @Published var state: State = .loading
    private let apiClient: RecipeService

    init(apiClient: RecipeService = APIClient()) {
        self.apiClient = apiClient
    }

    @MainActor
    func fetchRecipes(from url: URL) async {
        state = .loading
        do {
            let recipes = try await apiClient.fetchRecipes(from: url)
            state = .loaded(recipes)
            // TODO: change this to use func image below
            for recipe in recipes {
                if let url = recipe.photoURLSmall {
                    try? await cacheImage(from: url)
                }
            }
        } catch {
            state = .error(error)
        }
    }

    func image(for url: URL?) async -> UIImage? {
        guard let url = url else { return nil }
        return try? await ImageCache.shared.image(for: url)
    }

    func cacheImage(from url: URL) async throws {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard UIImage(data: data) != nil else {
            throw NSError(domain: "RecipeViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        
        let fileURL = ImageCache.shared.fileURL(for: url, response: response)
        try await ImageCache.shared.saveToDisk(data: data, fileURL: fileURL)
    }

    func cacheFileURL(for url: URL) -> URL {
        ImageCache.shared.fileURL(for: url)
    }
}
