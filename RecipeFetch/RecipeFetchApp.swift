//
//  RecipeFetchApp.swift
//  RecipeFetch
//
//  Created by Kevin Hewitt on 5/29/25.
//

import SwiftUI

@main
struct RecipeFetchApp: App {
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some Scene {
        WindowGroup {
            RecipeListView(viewModel: viewModel)
        }
    }
}
