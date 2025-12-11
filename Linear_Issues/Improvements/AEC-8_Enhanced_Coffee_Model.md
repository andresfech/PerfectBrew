# PRD: Enhanced Coffee Data Model & Precision Matching

## 🎯 Goal
Improve recommendation accuracy and user value by expanding the `Coffee` data model with high-signal attributes (Origin, Variety, Altitude) and practical metadata (Roast Date).

## 🧩 Gherkin User Stories

### Story 1: Matching by Origin
**Given** I have added a coffee from "Ethiopia"
**And** there is a V60 recipe profiled for "African/Ethiopian" coffees
**When** I view recommendations for this coffee
**Then** the V60 recipe should receive a score boost
**And** I should see "Matches Origin" as a reason

### Story 2: Matching by Variety
**Given** I have added a "Geisha" variety coffee
**And** there is a specific "Competition Style" recipe designed for delicate varieties
**When** I view recommendations
**Then** that recipe should be the top match
**And** I should see "Best for Geisha" as a reason

### Story 3: Tracking Freshness
**Given** I added a coffee with a roast date of 30 days ago
**When** I view my coffee list
**Then** I should see the roast date displayed
**And** (Optional Future) I might get a warning or a suggestion for "Old Coffee" recipes

## 🛠 Implementation Plan

### Phase 1: Data Model Expansion
**Objective**: Update data structures to store new fields.

- [ ] **Task 1.1**: Update `Coffee.swift` struct.
  - Add `country`: String (Required, but can be "Unknown")
  - Add `region`: String (Optional)
  - Add `variety`: String (Optional)
  - Add `altitude`: Int? (Optional, in meters)
  - Add `roastDate`: Date? (Optional)
- [ ] **Task 1.2**: Update `Recipe.swift` -> `RecipeProfile` struct.
  - Add `recommendedOrigins`: [String] (e.g., ["Ethiopia", "Kenya", "Colombia"])
  - Add `recommendedVarieties`: [String] (e.g., ["Geisha", "Bourbon", "Pacamara"])
- [ ] **Task 1.3**: Update `CoffeeRepository` migration logic (if needed, or clean install).

### Phase 2: UI Updates (Management)
**Objective**: Allow users to input and view new data.

- [ ] **Task 2.1**: Update `CoffeeFormViewModel` to handle new fields.
- [ ] **Task 2.2**: Update `CoffeeFormView`.
  - Add "Origin" Section (Country Picker or Text, Region Text, Altitude Text).
  - Add "Bean Details" Section (Variety Text).
  - Add "Roast Details" Section (DatePicker).
- [ ] **Task 2.3**: Update `CoffeeListView` / `CoffeeRow` to display Country and Roast Date prominentally.

### Phase 3: Enhanced Matching Logic
**Objective**: Use the new data to provide smarter scores.

- [ ] **Task 3.1**: Update `RecommendationService.swift`.
  - **Origin Match**: +15 points (Significant factor). Fuzzy string matching (e.g., "Ethiopia" matches "Ethiopian").
  - **Variety Match**: +10 points (Niche bonus).
- [ ] **Task 3.2**: Update `RecommendationServiceTests` with new scenarios.

## 📂 Affected Files
- `PerfectBrew/Models/Coffee.swift`
- `PerfectBrew/Models/Recipe.swift`
- `PerfectBrew/ViewModels/CoffeeFormViewModel.swift`
- `PerfectBrew/Views/MatchMyCoffee/CoffeeFormView.swift`
- `PerfectBrew/Views/MatchMyCoffee/CoffeeListView.swift`
- `PerfectBrew/Services/RecommendationService.swift`
- `PerfectBrewTests/RecommendationServiceTests.swift`

## 🛡 QA Strategy
1.  **Manual**: Add a "Geisha" coffee and verify the "Geisha" recipe (if added) scores 100%.
2.  **Manual**: Add an "Ethiopian" coffee and verify fruit-forward/light roast recipes score higher.
3.  **Automated**: Run `RecommendationServiceTests` to ensure point calculation is correct.

## 📊 Success Metrics
- Users can capture full details of their specialty coffee bags.
- Recommendations feel "smarter" because they acknowledge the specific bean origin/variety.

