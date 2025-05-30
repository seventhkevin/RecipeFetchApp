//
//  TestMocks.swift
//  RecipeFetchTests
//
//  Created by Kevin Hewitt on 5/30/25.
//
import Foundation
@testable import RecipeFetch

struct MockURLSession: URLSessionProtocol, @unchecked Sendable {
    let data: Data
    let response: URLResponse
    
    init(data: Data, response: URLResponse) {
        self.data = data
        self.response = response
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        (data, response)
    }
}

class MockFileManager: FileManager {
    var files: [String: Data] = [:]
    var createdDirectories: [String] = []
    var shouldThrowWriteError = false
    
    override func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]? = nil) throws {
        createdDirectories.append(url.path)
    }
    
    override func fileExists(atPath path: String) -> Bool {
        files[path] != nil
    }
    
    override func contents(atPath path: String) -> Data? {
        files[path]
    }
    
    override func createFile(atPath path: String, contents data: Data?, attributes: [FileAttributeKey: Any]? = nil) -> Bool {
        if shouldThrowWriteError {
            return false
        }
        files[path] = data
        return true
    }
    
    override func removeItem(at url: URL) throws {
        if createdDirectories.contains(url.path) {  // if we created the directory (cacheDirectory), we can remove all files
            files = [:]
        } else {
            files.removeValue(forKey: url.path)
        }
    }
    
    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        [URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Caches")]
    }
}
