//
//  URLSessionProtocol.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/30/25.
//
// For testing, to add data(from url: URL) for a mock session

import Foundation

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
