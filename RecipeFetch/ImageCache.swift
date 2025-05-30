//
//  ImageCache.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
import UIKit

actor ImageCache {
    static let shared = ImageCache()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDir.appendingPathComponent("RecipeImages")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func image(for url: URL) async throws -> UIImage? {
        let fileURL = fileURL(for: url)

        if let cachedImage = try await loadFromDisk(fileURL: fileURL) {
            return cachedImage
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            return nil
        }

        try await saveToDisk(image: image, fileURL: fileURL)
        return image
    }

    func loadFromDisk(fileURL: URL) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            if fileManager.fileExists(atPath: fileURL.path) {
                if let data = try? Data(contentsOf: fileURL),
                   let image = UIImage(data: data) {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }

    func saveToDisk(image: UIImage, fileURL: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
            if let data = image.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fileURL)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            } else {
                continuation.resume(throwing: NSError(domain: "ImageCache", code: -1, userInfo: nil))
            }
        }
    }

    func clearCache() async {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    nonisolated func fileURL(for url: URL) -> URL {
        // Use String.hashValue for a unique file name
        let urlString = url.absoluteString
        let hash = urlString.hashValue
        // Convert to base-36 for compact name
        let hashString = String(hash, radix: 36)
        // Get extension from URL, default to .jpg
        let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
        return cacheDirectory.appendingPathComponent("\(hashString).\(fileExtension)")
    }
}
