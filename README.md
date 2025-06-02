# RecipeFetch

A SwiftUI-based iOS app that fetches and displays recipes from a remote API, featuring a clean user interface, efficient image caching, and robust error handling. Built with Swift Concurrency, the app targets iOS 16+ and uses no external dependencies, emphasizing performance and maintainability.

## Summary

RecipeFetch allows users to browse a list of recipes, view detailed information, and share recipes via a share sheet. Key features include:
- **Recipe List**: Displays recipes with thumbnails, handling loading, empty, and error states, with sorting by name or cuisine.
- **Recipe Details**: Shows detailed recipe information, including large images and links.
- **Image Caching**: Efficiently caches images to reduce network requests, using raw data to preserve original formats.
- **Error Handling**: Gracefully manages network failures and invalid data.
- **Share Functionality**: Enables sharing recipe names and links.

**Screenshots**:
- ![Recipe List View](screenshots/recipe_list.png)
- ![Recipe Detail View](screenshots/recipe_detail.png)
- ![Empty State View](screenshots/empty_state.png)
- ![Error State View](screenshots/error_state.png)

**Video Demo** (optional):
- [Insert Video Link Here]

## Focus Areas

The project prioritized the following areas:
- **Swift Concurrency**: Leveraged `async/await` for network requests and UI updates, ensuring a smooth experience.
- **Efficient Image Caching**: Implemented a custom `ImageCache` actor to store raw image data, preserving formats.
- **Robust UI States**: Designed `RecipeListView` to handle multiple states with SwiftUI, including iOS 16/17 compatibility.
- **Testability**: Wrote comprehensive unit tests to verify API calls, caching, state management, and sorting.

These areas were chosen to meet the project’s requirements while delivering a user-friendly app.

## Time Spent

**Approximate Time**: ~40–50 hours

**Time Allocation**:
- **Design and Planning**: ~5 hours (architecture, data models, UI flow)
- **Implementation**: ~25 hours (core functionality, UI, share feature, sorting)
- **Testing**: ~10 hours (unit tests, bundle resources, sorting tests)
- **Debugging and Refinement**: ~5 hours (concurrency, `Equatable`, caching, sorting logic)

## Trade-offs and Decisions

- **Raw Data Caching**: Chose raw image data over JPEG compression for fidelity, increasing storage usage.
- **Non-@MainActor RecipeViewModel**: Removed `@MainActor` to simplify initialization, using it only on `fetchRecipes`.
- **Dependency Injection**: Used injection for `RecipeListView`, but kept `ImageCache.shared` as a singleton.
- **iOS 16+ Compatibility**: Added custom views for iOS 16, leveraging `ContentUnavailableView` for iOS 17+.
- **Sorting Implementation**: Added sorting by name or cuisine via a toolbar `Picker`, using `didSet` for reactive updates, prioritizing simplicity over advanced sorting (e.g., ascending/descending).

## Weakest Part of the Project

The weakest part is the `ImageCache.shared` singleton, which complicates testing. Injecting `ImageCache` into `RecipeViewModel` would improve testability but requires refactoring.

## Additional Information

- **Constraints**: No external dependencies, iOS 16+ compatibility, and API reliance on snake_case JSON.
- **Insights**: Swift Concurrency simplified logic, dependency injection improved modularity, and reactive sorting via `didSet` enhanced user interaction.
- **Future Improvements**: Add pagination, accessibility, `ImageCache` injection, and ascending/descending sort options.

[RecipeFetch on GitHub](https://github.com/yourusername/RecipeFetch)
