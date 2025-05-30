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
        } catch {
            state = .error(error)
        }
    }

    func image(for url: URL?) async -> UIImage? {
        guard let url = url else { return nil }
        return try? await ImageCache.shared.image(for: url)
    }

    func cacheImage(_ image: UIImage, for url: URL) async throws {
        try await ImageCache.shared.saveToDisk(image: image, fileURL: ImageCache.shared.fileURL(for: url))
    }

    func cacheFileURL(for url: URL) -> URL {
        ImageCache.shared.fileURL(for: url)
    }
}
