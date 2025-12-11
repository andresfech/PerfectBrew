## Relevant Files
- PerfectBrew/Models/BrewingScience.swift
- PerfectBrew/Models/Recipe.swift
- PerfectBrew/Services/KnowledgeBaseService.swift
- PerfectBrew/Resources/KnowledgeBase/VarietyProfiles.json
- PerfectBrew/Services/BrewingRuleEngine.swift
- PerfectBrew/Services/RecommendationService.swift

## Tasks

### Phase 1: Data Modeling (The Vocabulary)
- [ ] **Task 1**: Create `PerfectBrew/Models/BrewingScience.swift` with `ExtractionCharacteristics` struct and Enums (`AgitationLevel`, `ThermalEnergy`).
- [ ] **Task 2**: Update `PerfectBrew/Models/Recipe.swift` to include `extractionCharacteristics` property.
- [ ] **Task 3**: Create `PerfectBrew/Services/KnowledgeBaseService.swift` stub.

### Phase 2: Knowledge Base (The Database)
- [ ] **Task 1**: Create `PerfectBrew/Resources/KnowledgeBase/VarietyProfiles.json` with initial data (Geisha, Bourbon, Caturra).
- [ ] **Task 2**: Create `PerfectBrew/Resources/KnowledgeBase/ProcessProfiles.json` with initial data (Washed, Natural, Honey).
- [ ] **Task 3**: Implement `KnowledgeBaseService` loading logic to parse these JSONs.

### Phase 3: The Rule Engine (Layer 1)
- [ ] **Task 1**: Create `PerfectBrew/Services/BrewingRuleEngine.swift`.
- [ ] **Task 2**: Implement `computeTargetProfile(for coffee: Coffee) -> ExtractionCharacteristics` logic using the Knowledge Base.
- [ ] **Task 3**: Create unit tests `BrewingRuleEngineTests.swift` to verify "Geisha" and "Natural" rules.

### Phase 4: The Matcher & Migration (Layer 2)
- [ ] **Task 1**: Refactor `RecommendationService.swift` to use `BrewingRuleEngine` and implement vector distance scoring.
- [ ] **Task 2**: Update `RecommendationsView.swift` to display the new "Intent-based" reasons.
- [ ] **Task 3**: Update key recipes (Tim Wendelboe, Tetsu) with `extraction_characteristics` in their JSON files.
