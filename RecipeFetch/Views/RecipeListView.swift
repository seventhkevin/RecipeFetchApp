//
//  RecipeListView.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
import SwiftUI

struct RecipeListView: View {
    @StateObject private var viewModel: RecipeViewModel
    private let shouldFetchOnAppear: Bool

    init(viewModel: RecipeViewModel = RecipeViewModel(), shouldFetchOnAppear: Bool = true) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.shouldFetchOnAppear = shouldFetchOnAppear
    }

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading recipes...")
                case .loaded(let recipes):
                    if recipes.isEmpty {
                        if #available(iOS 17.0, *) {
                            ContentUnavailableView(
                                "No Recipes Available",
                                systemImage: "fork.knife.circle",
                                description: Text("There are no recipes to display at this time.")
                            )
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "fork.knife.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                Text("No Recipes Available")
                                    .font(.headline)
                                Text("There are no recipes to display at this time.")
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        List(recipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                                RecipeRow(recipe: recipe, viewModel: viewModel)
                            }
                        }
                    }
                case .error(let error):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text("Error Loading Recipes")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task { await viewModel.fetchRecipes(from: Constants.API.baseRecipesURL) }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortOption) {
                            ForEach(RecipeViewModel.SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .task {
                if shouldFetchOnAppear {
                    await viewModel.fetchRecipes(from: Constants.API.baseRecipesURL)
                }
            }
        }
    }
}

// Helper function to create mock recipes
private func makeMockRecipes() -> [Recipe] {
    [
        Recipe(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
            cuisine: "Italian",
            name: "Spaghetti Carbonara",
            photoURLLarge: URL(string: "https://example.com/large.jpg"),
            photoURLSmall: URL(string: "https://example.com/small.jpg"),
            sourceURL: URL(string: "https://example.com/recipe"),
            youtubeURL: URL(string: "https://youtube.com/watch?v=123")
        ),
        Recipe(
            id: UUID(uuidString: "223e4567-e89b-12d3-a456-426614174001")!,
            cuisine: "Mexican",
            name: "Tacos"
        )
    ]
}

// Helper function to create mock view model
private func makeMockViewModel(state: RecipeViewModel.State) -> RecipeViewModel {
    let viewModel = RecipeViewModel(apiClient: MockRecipeService(recipes: makeMockRecipes()))
    viewModel.state = state
    return viewModel
}

#Preview("Loaded State") {
    RecipeListView(
        viewModel: makeMockViewModel(state: .loaded(makeMockRecipes())),
        shouldFetchOnAppear: false
    )
}

#Preview("Empty State") {
    RecipeListView(
        viewModel: makeMockViewModel(state: .loaded([])),
        shouldFetchOnAppear: false
    )
}

#Preview("Error State") {
    RecipeListView(
        viewModel: makeMockViewModel(state: .error(APIError.invalidResponse)),
        shouldFetchOnAppear: false
    )
}

// Mock RecipeService for previews
struct MockRecipeService: RecipeService {
    let recipes: [Recipe]
    
    func fetchRecipes(from url: URL) async throws -> [Recipe] {
        recipes
    }
}
