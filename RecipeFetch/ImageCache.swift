//
//  ImageCache.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//
import UIKit

actor ImageCache {
    static let shared = ImageCache()
    
    private var fileManager: FileManager
    private let cacheDirectory: URL
    private var urlSession: URLSessionProtocol

    init() {
        self.fileManager = FileManager.default
        self.urlSession = URLSession.shared
        let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDir.appendingPathComponent("RecipeImages")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    init(fileManager: FileManager, urlSession: URLSessionProtocol = URLSession.shared) {
        self.fileManager = fileManager
        self.urlSession = urlSession
        let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDir.appendingPathComponent("RecipeImages")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func image(for url: URL) async throws -> UIImage? {
        let cacheURL = fileURL(for: url)

        if let cachedImage = try await loadFromDisk(fileURL: cacheURL) {
            return cachedImage
        }

        let (data, response) = try await urlSession.data(from: url)
        guard let image = UIImage(data: data) else {
            return nil
        }

        // Use response MIME type for file extension
        let finalCacheURL = fileURL(for: url, response: response)
        try await saveToDisk(data: data, fileURL: finalCacheURL)
        return image
    }
    
    func loadFromDisk(fileURL: URL) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            if fileManager.fileExists(atPath: fileURL.path) {
                if let data = fileManager.contents(atPath: fileURL.path),
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

    func saveToDisk(data: Data, fileURL: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
            if fileManager.createFile(atPath: fileURL.path, contents: data, attributes: nil) {
                continuation.resume()
            } else {
                continuation.resume(throwing: NSError(domain: "ImageCache", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to write data to disk"]))
            }
        }
    }

    func clearCache() async {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    nonisolated func fileURL(for url: URL, response: URLResponse? = nil) -> URL {
        let urlString = url.absoluteString
        let hash = urlString.hashValue
        let hashString = String(hash, radix: 36)
        // Use MIME type from response if available, else fall back to URL extension or .jpg
        var fileExtension = "jpg"
        if let httpResponse = response as? HTTPURLResponse,
           let mimeType = httpResponse.mimeType {
            if mimeType == "image/png" {
                fileExtension = "png"
            } else if mimeType == "image/jpeg" {
                fileExtension = "jpg"
            }
        } else if !url.pathExtension.isEmpty {
            fileExtension = url.pathExtension
        }
        return cacheDirectory.appendingPathComponent("\(hashString).\(fileExtension)")
    }
}
