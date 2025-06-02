//
//  RecipeListView.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
import SwiftUI

struct RecipeListView: View {
    @ObservedObject var viewModel: RecipeViewModel
    private let shouldFetchOnAppear: Bool

    init(viewModel: RecipeViewModel, shouldFetchOnAppear: Bool = true) {
        self.viewModel = viewModel // Direct assignment
        self.shouldFetchOnAppear = shouldFetchOnAppear
    }

    private var isSortAvailable: Bool {
        if case .loaded(let recipes) = viewModel.state {
            return recipes.count > 1
        }
        return false
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    Group {
                        switch viewModel.state {
                        case .loading:
                            VStack {
                                ProgressView("Loading recipes...")
                                    .padding()
                            }
                            .frame(minHeight: geometry.size.height)
                            .frame(maxWidth: .infinity, alignment: .center)
                        case .loaded(let recipes):
                            if recipes.isEmpty {
                                VStack {
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
                                }
                                .frame(minHeight: geometry.size.height)
                                .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(recipes) { recipe in
                                        HStack {
                                            // NavigationLink with RecipeRow and chevron
                                            NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                                                HStack {
                                                    RecipeRow(recipe: recipe, viewModel: viewModel)
                                                    // Add chevron indicator on the right
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                                                        .padding(.trailing, 8)
                                                }
                                            }
                                        }
                                        .frame(alignment: .leading)
                                        .padding(.horizontal)
                                        Divider()
                                    }
                                }
                            }
                        case .error(let error):
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.red)
                                Text("Error Loading Recipes")
                                    .font(.headline)
                                Text(error.localizedDescription)
                                    .foregroundColor(.secondary)
                            }
                            .frame(minHeight: geometry.size.height)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .refreshable {
                    await viewModel.fetchRecipes(from: Constants.API.baseRecipesURL)
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                if isSortAvailable {
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

#Preview("Loading State") {
    RecipeListView(
        viewModel: makeMockViewModel(state: .loading),
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
