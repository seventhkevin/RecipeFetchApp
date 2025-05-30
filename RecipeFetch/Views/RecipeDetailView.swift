//
//  RecipeDetailView.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var viewModel: RecipeViewModel
    @State private var largeImage: UIImage?
    @State private var smallImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let image = largeImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .frame(height: 200)
                }
                Text(recipe.name)
                    .font(.title)
                Text("Cuisine: \(recipe.cuisine)")
                    .font(.subheadline)
                if let sourceURL = recipe.sourceURL {
                    Link("View Source", destination: sourceURL)
                        .font(.subheadline)
                }
                if let youtubeURL = recipe.youtubeURL {
                    Link("Watch on YouTube", destination: youtubeURL)
                        .font(.subheadline)
                }
                // Share button using ShareLink
                ShareLink(
                    item: shareText(),
                    subject: Text("\(recipe.name) Recipe"),
                    preview: SharePreview(
                        recipe.name,
                        image: smallImage.map { Image(uiImage: $0) } ?? Image(systemName: "fork.knife.circle")
                    )
                ) {
                    Label("Share Recipe", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .task {
            async let largeImageTask = viewModel.image(for: recipe.photoURLLarge)
            async let smallImageTask = viewModel.image(for: recipe.photoURLSmall)
            largeImage = await largeImageTask
            smallImage = await smallImageTask
        }
    }

    // Prepare share text (name, URLs)
    private func shareText() -> String {
        var text = "Check out this recipe: \(recipe.name)"
        
        if let sourceURL = recipe.sourceURL {
            text += "\nRecipe: \(sourceURL.absoluteString)"
        }
        
        if let youtubeURL = recipe.youtubeURL {
            text += "\nVideo: \(youtubeURL.absoluteString)"
        }
        
        return text
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
    
    // Cache mock images synchronously
    let mockImage = UIImage(systemName: "photo")!
    for url in [mockRecipe.photoURLLarge, mockRecipe.photoURLSmall].compactMap({ $0 }) {
        let fileURL = viewModel.cacheFileURL(for: url)
        if let data = mockImage.jpegData(compressionQuality: 1.0) {
            try? data.write(to: fileURL)
        }
    }
    
    return (mockRecipe, viewModel)
}

#Preview("With Share Button") {
    let (mockRecipe, viewModel) = createMockRecipeAndViewModel()
    RecipeDetailView(recipe: mockRecipe, viewModel: viewModel)
}
