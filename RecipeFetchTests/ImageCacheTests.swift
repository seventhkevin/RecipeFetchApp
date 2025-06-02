//
//  ImageCacheTests.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/30/25.
//
import XCTest
@testable import RecipeFetch
import UIKit

final class ImageCacheTests: XCTestCase {
    var imageCache: ImageCache!
    fileprivate var mockFileManager: MockFileManager!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockFileManager = MockFileManager()
        mockURLSession = MockURLSession(data: Data(), response: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        imageCache = ImageCache(fileManager: mockFileManager, urlSession: mockURLSession)
    }
    
    override func tearDown() async throws {
        await imageCache.clearCache()
        imageCache = nil
        mockFileManager = nil
        mockURLSession = nil
        try await super.tearDown()
    }
    
    func testUniqueFileNames() {
        let url1 = URL(string: "https://example.com/image1.jpg")!
        let url2 = URL(string: "https://example.com/image2.jpg")!
        let url3 = URL(string: "https://example.com/image3.png")!
        
        let fileURL1 = imageCache.fileURL(for: url1)
        let fileURL2 = imageCache.fileURL(for: url2)
        let fileURL3 = imageCache.fileURL(for: url3)
        
        XCTAssertNotEqual(fileURL1.lastPathComponent, fileURL2.lastPathComponent, "File names should be unique for different URLs")
        XCTAssertNotEqual(fileURL1.lastPathComponent, fileURL3.lastPathComponent, "File names should be unique for different URLs")
        XCTAssertTrue(fileURL1.lastPathComponent.hasSuffix(".jpg"), "Should use .jpg extension")
        XCTAssertTrue(fileURL3.lastPathComponent.hasSuffix(".png"), "Should use .png extension")
    }
    
    func testFileNameWithNoExtension() {
        let url = URL(string: "https://example.com/image")!
        
        let fileURL = imageCache.fileURL(for: url)
        
        XCTAssertTrue(fileURL.lastPathComponent.hasSuffix(".jpg"), "Should default to .jpg for extensionless URLs")
    }
    
    func testCacheAndLoadImage() async throws {
        let url = URL(string: "https://example.com/image.jpg")!
        let imageData = try loadImageData()
        let image = UIImage(data: imageData)!
        let fileURL = imageCache.fileURL(for: url)
        
        try await imageCache.saveToDisk(data: imageData, fileURL: fileURL)
        
        XCTAssertNotNil(mockFileManager.files[fileURL.path], "Image data should be cached")
        XCTAssertEqual(mockFileManager.files[fileURL.path], imageData, "Cached data should match original")
        
        let loadedImage = try await imageCache.loadFromDisk(fileURL: fileURL)
        
        XCTAssertNotNil(loadedImage, "Should load cached image")
        XCTAssertEqual(loadedImage?.size, image.size, "Loaded image dimensions should match original")
    }
    
    func testLoadNonExistentImage() async throws {
        let url = URL(string: "https://example.com/nonexistent.jpg")!
        let fileURL = imageCache.fileURL(for: url)
        
        let loadedImage = try await imageCache.loadFromDisk(fileURL: fileURL)
        
        XCTAssertNil(loadedImage, "Should return nil for non-cached image")
    }
    
    func testSaveImageWithFileSystemError() async throws {
        let url = URL(string: "https://example.com/image.jpg")!
        let image = UIImage(systemName: "photo")!
        let fileURL = imageCache.fileURL(for: url)
        
        let imageData = try XCTUnwrap(image.jpegData(compressionQuality: 1.0))
        mockFileManager.shouldThrowWriteError = true
        
        do {
            try await imageCache.saveToDisk(data: imageData, fileURL: fileURL)
            XCTFail("Expected file system error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "ImageCache", "Error domain should be ImageCache")
            XCTAssertEqual(error.code, -2, "Error code should be -2")
            XCTAssertNil(mockFileManager.files[fileURL.path], "No file should be written")
        }
    }
    
    func testClearCache() async {
        let url1 = URL(string: "https://example.com/image1.jpg")!
        let url2 = URL(string: "https://example.com/image2.png")!
        let fileURL1 = imageCache.fileURL(for: url1)
        let fileURL2 = imageCache.fileURL(for: url2)
        
        mockFileManager.files[fileURL1.path] = Data()
        mockFileManager.files[fileURL2.path] = Data()
        
        await imageCache.clearCache()
        
        XCTAssertTrue(mockFileManager.files.isEmpty, "Cache should be cleared")
        let sampleURL = URL(string: "https://example.com/sample.jpg")!
        let sampleFileURL = imageCache.fileURL(for: sampleURL)
        let cacheDirPath = sampleFileURL.deletingLastPathComponent().path
        XCTAssertTrue(mockFileManager.createdDirectories.contains(cacheDirPath), "Cache directory should be recreated")
    }
    
    func testImageForURLWithJPEG() async throws {
        let url = URL(string: "https://example.com/image.jpg")!
        let imageData = try loadImageData()
        let image = UIImage(data: imageData)!
        mockURLSession = MockURLSession(data: imageData, response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/jpeg"])!)
        imageCache = ImageCache(fileManager: mockFileManager, urlSession: mockURLSession)
        
        let fileURL = imageCache.fileURL(for: url, response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/jpeg"])!)
        
        let fetchedImage = try await imageCache.image(for: url)
        
        XCTAssertNotNil(fetchedImage, "Should fetch image")
        XCTAssertEqual(fetchedImage?.size, image.size, "Fetched image dimensions should match")
        XCTAssertNotNil(mockFileManager.files[fileURL.path], "Image data should be cached")
        XCTAssertEqual(mockFileManager.files[fileURL.path], imageData, "Cached data should match downloaded data")
        XCTAssertTrue(fileURL.pathExtension == "jpg", "Should use .jpg extension for JPEG")
    }
    
    func testImageForURLWithPNG() async throws {
        let url = URL(string: "https://example.com/image.png")!
        let imageData = try loadImageData()
        let image = UIImage(data: imageData)!
        let pngimageData = try XCTUnwrap(image.pngData())
        mockURLSession = MockURLSession(data: pngimageData, response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/png"])!)
        imageCache = ImageCache(fileManager: mockFileManager, urlSession: mockURLSession)
        
        let fileURL = imageCache.fileURL(for: url, response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/png"])!)
        
        let fetchedImage = try await imageCache.image(for: url)
        
        XCTAssertNotNil(fetchedImage, "Should fetch image")
        XCTAssertEqual(fetchedImage?.size, image.size, "Fetched image dimensions should match")
        XCTAssertNotNil(mockFileManager.files[fileURL.path], "Image data should be cached")
        XCTAssertEqual(mockFileManager.files[fileURL.path], pngimageData, "Cached data should match downloaded data")
        XCTAssertTrue(fileURL.pathExtension == "png", "Should use .png extension for PNG")
    }
    
    func loadImageData() throws -> Data {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: "IMG_5570", withExtension: "jpg") else {
            XCTFail("Could not find IMG_5570.jpg in test bundle")
            throw NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not found"])
        }
        return try Data(contentsOf: url)
    }

}
