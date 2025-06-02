//
//  RecipeRow.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe
    let viewModel: RecipeViewModel
    @State private var image: UIImage?

    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            image = await viewModel.image(for: recipe.photoURLSmall)
        }
    }
}

private func createMockRecipeAndViewModel() -> (Recipe, RecipeViewModel) {
    let mockRecipe = Recipe(
        id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
        cuisine: "Italian",
        name: "Spaghetti Carbonara",
        photoURLLarge: URL(string: "https://example.com/large.jpg"),
        photoURLSmall: URL(string: "https://example.com/small.jpg"),
        sourceURL: URL(string: "https://example.com/recipe"),
        youtubeURL: URL(string: "https://youtube.com/watch?v=123")
    )
    
    let viewModel = RecipeViewModel(apiClient: MockRecipeService(recipes: [mockRecipe]))
    
    // Cache mock image synchronously
    let mockImage = UIImage(systemName: "photo")!
    if let url = mockRecipe.photoURLSmall {
        let fileURL = viewModel.cacheFileURL(for: url)
        if let data = mockImage.jpegData(compressionQuality: 1.0) {
            try? data.write(to: fileURL)
        }
    }
    
    return (mockRecipe, viewModel)
}

#Preview {
    let (mockRecipe, viewModel) = createMockRecipeAndViewModel()
    RecipeRow(recipe: mockRecipe, viewModel: viewModel)
}
