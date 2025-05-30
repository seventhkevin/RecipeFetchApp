//
//  Recipe.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
// let decoder = JSONDecoder()
// decoder.keyDecodingStrategy = .convertFromSnakeCase
/*
 func fetchRecipes(from url: URL) async throws -> [Recipe] {
     let (data, _) = try await URLSession.shared.data(from: url)
     let decoder = JSONDecoder()
     decoder.keyDecodingStrategy = .convertFromSnakeCase
     return try decoder.decode([Recipe].self, from: data)
 }
 */

import Foundation

struct Recipe: Codable, Identifiable {
    let id: UUID
    let cuisine: String
    let name: String
    let photoURLLarge: URL?
    let photoURLSmall: URL?
    let sourceURL: URL?
    let youtubeURL: URL?

    // Memberwise initializer for manual creation (e.g., in previews)
    init(
        id: UUID,
        cuisine: String,
        name: String,
        photoURLLarge: URL? = nil,
        photoURLSmall: URL? = nil,
        sourceURL: URL? = nil,
        youtubeURL: URL? = nil
    ) {
        self.id = id
        self.cuisine = cuisine
        self.name = name
        self.photoURLLarge = photoURLLarge
        self.photoURLSmall = photoURLSmall
        self.sourceURL = sourceURL
        self.youtubeURL = youtubeURL
    }

    // CodingKeys for snake_case JSON keys
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case cuisine
        case name
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }

    // Custom decoding for UUID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uuidString = try container.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: uuidString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "Invalid UUID string"
            )
        }
        self.id = uuid
        self.cuisine = try container.decode(String.self, forKey: .cuisine)
        self.name = try container.decode(String.self, forKey: .name)
        self.photoURLLarge = try container.decodeIfPresent(URL.self, forKey: .photoURLLarge)
        self.photoURLSmall = try container.decodeIfPresent(URL.self, forKey: .photoURLSmall)
        self.sourceURL = try container.decodeIfPresent(URL.self, forKey: .sourceURL)
        self.youtubeURL = try container.decodeIfPresent(URL.self, forKey: .youtubeURL)
    }
}
