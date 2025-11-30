## Relevant Files
- PerfectBrew/Models/Recipe.swift – Data model for recipes
- PerfectBrew/RecipeSelectionScreen.swift – UI for selecting recipes

## Tasks
### Phase 1: Data Cleanup & Core Logic
- [x] Task 1: Delete all `*_two_people.json`, `*_three_people.json`, `*_four_people.json` files from `Resources/Recipes`.
- [x] Task 2: Update `Recipe.swift` to implement `func scaled(to targetCoffeeGrams: Double) -> Recipe`. (Implemented but currently unused in UI)
- [x] Task 3: Verify `RecipeDatabase` loads only the single-serve recipes correctly.

### Phase 2: UI Implementation
- [x] Task 1: Modify `RecipeSelectionScreen.swift` to replace Servings Filter with Dose Range Filter (<15g, 15-20g, >20g).
- [x] Task 2: Update `filteredRecipes` computed property to filter by dose range.
- [x] Task 3: Update `BrewDetailScreen` to indicate parameters (Verified: Displays original recipe params).

### Phase 3: Refinement & Safety
- [x] Task 1: Verify filter logic covers edge cases (Ranges cover all values).
- [x] Task 2: Verify audio handling (Matches text as no scaling is applied).
