## Relevant Files
- PerfectBrew/Models/Recipe.swift
- PerfectBrew/Models/Coffee.swift
- PerfectBrew/Services/CoffeeRepository.swift
- PerfectBrew/Services/RecommendationService.swift
- PerfectBrew/Views/Home/HomeScreen.swift

## Tasks

### Phase 1: Data Architecture & Persistence
- [x] **Task 1**: Create `PerfectBrew/Models/Coffee.swift` with Enums (`RoastLevel`, `Process`, `FlavorTag`).
- [x] **Task 2**: Update `PerfectBrew/Models/Recipe.swift` to include `RecipeProfile` struct. Ensure backward compatibility (optional decoding).
- [x] **Task 3**: Create `PerfectBrew/Services/CoffeeRepository.swift` to handle CRUD operations for `Coffee` entities (saving to a local JSON file in Documents directory).

### Phase 2: Scoring Logic (The Brain)
- [x] **Task 1**: Create `PerfectBrew/Services/RecommendationService.swift` prototype. Implement the matching algorithm: `match(coffee, recipe) -> Score`.
- [x] **Task 2**: Implement the "Reasoning" generator: `generateReasons(coffee, recipe) -> [String]` based on the match details.
- [x] **Task 3**: Create `RecommendationServiceTests.swift` and validate the algorithm with at least 3 test cases (Perfect Match, Partial Match, No Match).

### Phase 3: UI - Management & Entry
- [x] **Task 1**: Create `CoffeeViewModel` and `CoffeeFormView` (SwiftUI) for adding/editing a coffee bag.
- [x] **Task 2**: Create `CoffeeListViewModel` and `CoffeeListView` to display saved coffees.
- [x] **Task 3**: Update `HomeScreen` to add the "Match My Coffee" button/section navigating to the Coffee List.

### Phase 4: UI - Recommendations & Integration
- [x] **Task 1**: Create `RecommendationsViewModel` that uses `RecommendationService` to sort recipes for a given coffee.
- [x] **Task 2**: Create `RecommendationsView` to display the sorted results with "Match Score" and "Reasons" pills.
- [x] **Task 3**: Update a few key recipes (e.g., 5 varied ones) in `Resources/Recipes/...` with `recipe_profile` data to demonstrate the feature works.
