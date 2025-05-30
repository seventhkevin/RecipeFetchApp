//
//  Constants.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//


import Foundation

enum Constants {
    enum API {
        static let baseRecipesURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
        static let malformedRecipesURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!
        static let emptyRecipesURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
    }
}