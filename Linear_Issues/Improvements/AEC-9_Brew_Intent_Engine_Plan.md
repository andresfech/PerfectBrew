# PRD: 2-Layer Brew Intent Recommendation Engine

## 🎯 Goal
Refactor the recommendation logic to model **brewing intent** (Physics & Chemistry) rather than metadata matching. This creates a "Coffee Sommelier" logic that understands *why* a recipe works for a specific bean.

## 🧠 Core Concept: The 2-Layer Engine

### Layer 1: Coffee → Extraction Strategy (The "Why")
**Input**: Coffee Bean Data (Variety, Process, Roast, Altitude, Origin)
**Logic**: Deterministic Rule Engine
**Output**: `ExtractionProfile`
*   **Clarity vs Body**: (0.0 Body - 1.0 Clarity)
*   **Acidity Focus**: (Low/Med/High)
*   **Agitation Tolerance**: (Low/Med/High) - e.g., Naturals produce fines, low agitation.
*   **Thermal Mass Needed**: (Low/Med/High) - Light roasts need high thermal mass.

### Layer 2: Extraction Strategy → Recipe Match (The "How")
**Input**: `ExtractionProfile` + Available Recipes
**Logic**: Vector-like Distance Matching (Euclidean distance on characteristics)
**Output**: Scored Recipe List

## 🛠 Implementation Plan

### Phase 1: Data Modeling (The Vocabulary)
**Objective**: Define the language of extraction.

- [ ] **Task 1.1**: Create `ExtractionCharacteristics` struct in `Models/BrewingScience.swift`.
  - Properties: `clarity`, `acidity`, `sweetness`, `body` (Double 0-1).
  - Properties: `agitationLevel` (Enum: low, medium, high).
  - Properties: `thermalEnergy` (Enum: low, medium, high).
- [ ] **Task 1.2**: Update `Recipe` model to include `extractionCharacteristics`.
  - Migrate existing `recipeProfile` to this new structure (e.g., "High Clarity" for Tetsu).

### Phase 1.5: Knowledge Base (The Database)
**Objective**: Externalize brewing wisdom into data files, not code.

- [ ] **Task 1.5.1**: Create `Resources/KnowledgeBase/VarietyProfiles.json`.
  - Database of varieties (Geisha, Bourbon, Pacamara, Caturra, etc.) with their default `ExtractionCharacteristics`.
  - *Example*: Geisha -> { Clarity: 0.9, Agitation: Low }.
- [ ] **Task 1.5.2**: Create `Resources/KnowledgeBase/ProcessProfiles.json`.
  - Database of processes (Washed, Natural, Honey, Anaerobic) with their physical constraints.
  - *Example*: Natural -> { Agitation: Low (fines), FlowRate: Slow }.
- [ ] **Task 1.5.3**: Create `KnowledgeBaseService.swift` to load and query these profiles.

### Phase 2: The Rule Engine (Layer 1)
**Objective**: Translate Bean Data into Extraction Needs using the Knowledge Base.

- [ ] **Task 2.1**: Create `BrewingRuleEngine.swift`.
  - Define `Rule` struct: `Condition` (Closure) -> `Effect` (Modification of characteristics).
- [ ] **Task 2.2**: Implement core rules logic.
  - **Base Layer**: Load `VarietyProfile` (if match).
  - **Modifier Layer**: Apply `ProcessProfile` modifiers.
  - **Physics Layer**: Apply Density/Roast rules (High Altitude -> High Temp).

### Phase 3: The Matcher (Layer 2)
**Objective**: Find the recipe that fits the need.

- [ ] **Task 3.1**: Refactor `RecommendationService` to use `BrewingRuleEngine`.
  - Step 1: `let targetProfile = engine.computeProfile(for: coffee)`
  - Step 2: `score = distance(targetProfile, recipe.characteristics)`
- [ ] **Task 3.2**: Implement "Explanation Generator".
  - Instead of "Matches Origin", say: "Selected for High Clarity to highlight Geisha notes."

### Phase 4: Data Migration & UI
**Objective**: Update existing content to the new paradigm.

- [ ] **Task 4.1**: Update JSON recipes (Tim Wendelboe, Hoffmann, etc.) with `extraction_characteristics`.
  - *Example*: Tetsu Kasuya 4:6 -> Clarity: 0.9, Agitation: Low.
- [ ] **Task 4.2**: Update `RecommendationView` UI to visualize the "Fit".
  - Show a "Radar Chart" or simple bars comparing "Coffee Needs" vs "Recipe Provides".

## 📊 Success Metrics
- **"Geisha Test"**: A Geisha coffee automatically recommends low-agitation, high-clarity recipes without hardcoding "Geisha" in the recipe itself.
- **"Natural Test"**: A Natural coffee avoids recipes with "Heavy Agitation" (to avoid clogging).

## 🛡 Scope & Boundaries
- **No AI**: Pure deterministic logic. Predictable and debuggable.
- **Backward Compatibility**: Fallback to basic scoring if recipe lacks new metadata.

