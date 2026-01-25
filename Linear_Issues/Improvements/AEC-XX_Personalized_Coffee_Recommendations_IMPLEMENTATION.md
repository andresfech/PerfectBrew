# Personalized Coffee Recommendations - Implementation Plan

## 📊 PRD Review & Completeness Score

### Completeness Score: **8/10**

**Strengths:**
- ✅ Clear goals and comprehensive Gherkin stories
- ✅ Well-defined functional requirements with sub-requirements
- ✅ Proper architecture alignment with MVVM pattern
- ✅ Investigation decisions documented
- ✅ Clear non-goals and scope boundaries

**Gaps Identified:**
- ⚠️ Missing specific preference adjustment formulas (exact score boost amounts)
- ⚠️ Method highlighting algorithm needs more detail (scoring calculation)
- ⚠️ Body texture question display logic (when to show conditionally)
- ⚠️ Error handling for incomplete preferences
- ⚠️ Specific localization keys needed (list all required strings)
- ⚠️ Navigation flow implementation details (NavigationLink vs programmatic)

### PerfectBrew Consistency Check: ✅ PASS
- Follows MVVM pattern (RecommendationsViewModel)
- Uses @Published properties for state
- Uses NavigationLink (consistent with CoffeeListView pattern)
- Uses chip selection pattern (consistent with RecipeSelectionScreen FilterChip pattern)
- Follows localization pattern (LocalizationManager)

---

## 🚀 Executable Implementation Plan

### Phase 1: Models & Data Structures
- [ ] **Task 1**: Create `PerfectBrew/Models/UserTastePreferences.swift` with enums: `BodyPreference`, `BodyTexture`, `AcidityPreference`, `SweetnessPreference`, `RecommendationType`, and `UserTastePreferences` struct
- [ ] **Task 2**: Add helper methods to `UserTastePreferences` to convert preferences to `ExtractionCharacteristics` adjustments (body value mapping, clarity adjustment for texture, acidity adjustment, sweetness adjustment)
- [ ] **Task 3**: Verify `ExtractionCharacteristics` model supports the adjustments needed (clarity, acidity, sweetness, body are all Double values 0.0-1.0)

### Phase 2: Preference Questionnaire UI
- [ ] **Task 1**: Create `PerfectBrew/Views/MatchMyCoffee/PreferenceQuestionnaireView.swift` with Form layout and sections for each preference question
- [ ] **Task 2**: Implement chip selection UI (similar to FilterChip in RecipeSelectionScreen) for body preference (Light/Medium/Full), acidity preference (Bright/Juicy vs Smooth/Low), and sweetness preference (Sweet/Balanced/Bitter)
- [ ] **Task 3**: Add conditional body texture question (Tea-like vs Creamy/Syrupy) that shows when body preference is selected, add recommendation type selector (General vs Method-specific), and add method picker (if method-specific selected)

### Phase 3: Navigation Flow Integration
- [ ] **Task 1**: Modify `CoffeeListView.swift` to navigate to `PreferenceQuestionnaireView` instead of directly to `RecommendationsView` when coffee is tapped
- [ ] **Task 2**: Update `PreferenceQuestionnaireView` to accept `coffee: Coffee` parameter and handle navigation to `RecommendationsView` on completion
- [ ] **Task 3**: Add "Skip" button to `PreferenceQuestionnaireView` that navigates directly to recommendations without preferences (pass nil preferences)

### Phase 4: Preference-Based Scoring Algorithm
- [ ] **Task 1**: Modify `RecommendationService.getRecommendations()` to accept optional `UserTastePreferences` parameter
- [ ] **Task 2**: Create `adjustTargetProfile()` method in `RecommendationService` that takes base target profile and user preferences, returns adjusted profile using weighted blend (70% coffee characteristics, 30% preferences)
- [ ] **Task 3**: Modify `calculateScore()` to use adjusted target profile when preferences provided, and add preference alignment bonus (+5 to +15 points based on how well recipe matches preferences)

### Phase 5: Method Highlighting Logic
- [ ] **Task 1**: Create `methodHighlightScore()` helper method in `RecommendationService` that evaluates method capability matrix (V60: clarity=0.9, body=0.3; AeroPress: clarity=0.6, body=0.6; French Press: clarity=0.2, body=0.9; Chemex: clarity=0.95, body=0.2)
- [ ] **Task 2**: Calculate method highlighting score by comparing method capabilities to coffee's dominant characteristics (fruity/bright → V60/Chemex, body-forward → French Press, versatile → AeroPress)
- [ ] **Task 3**: Add method highlighting bonus (+10 to +20 points) to recipe scores when method aligns well with coffee characteristics, and add reason tags like "Highlights coffee's brightness" or "Emphasizes body"

### Phase 6: Localization & Display
- [ ] **Task 1**: Add localization strings to `LocalizationManager.swift` for all preference questions, options, and contextual hints (English and Spanish)
- [ ] **Task 2**: Update `RecommendationsView` to show preference-adjusted reasons (e.g., "Matches your preference for full body", "V60 highlights fruity notes")
- [ ] **Task 3**: Update `RecommendationsViewModel` to accept and pass preferences to `RecommendationService`, handle method-specific filtering when `recommendationType == .methodSpecific`

---

## 🔍 Investigation Resolutions

### I1: Preference Weighting Strategy ✅
**Decision**: Use 70% coffee characteristics, 30% preferences (weighted blend in `adjustTargetProfile()`)
**Implementation**: `adjustedValue = coffeeValue * 0.7 + preferenceValue * 0.3`

### I2: Body Texture Mapping ✅
**Decision**: 
- Tea-like → clarity = 0.8-1.0, body = 0.2-0.4
- Creamy/Syrupy → clarity = 0.3-0.5, body = 0.7-1.0
**Implementation**: When body texture selected, adjust clarity: tea-like = +0.3 to clarity (capped at 1.0), creamy/syrupy = -0.2 to clarity, +0.3 to body (capped at 1.0)

### I3: Acidity Preference Impact ✅
**Decision**: Apply ±0.25 adjustment to target acidity
**Implementation**: Bright/Juicy preference = +0.25 to target acidity (capped at 1.0), Smooth/Low = -0.25 (floored at 0.0)

### I4: Method Highlighting Scoring ✅
**Decision**: Use predefined method capability matrix, match against coffee's primary characteristics
**Implementation**: 
- Calculate coffee's dominant attribute (highest value: clarity, acidity, body, or sweetness)
- Score methods: if method capability aligns with dominant attribute (>0.6 match), add +15 bonus
- If method capability aligns with user preference (>0.6 match), add +10 bonus

### I5: Preference Persistence ✅
**Decision**: Session-only for MVP (store in ViewModel, not persisted)
**Implementation**: Preferences passed via navigation from questionnaire to recommendations view, not saved to disk

---

## 📝 Additional Implementation Details

### Preference Adjustment Formulas

**Body Preference Mapping:**
- Light → target body = 0.3
- Medium → target body = 0.5
- Full → target body = 0.7

**Body Texture Adjustment:**
- Tea-like selected → clarity += 0.3 (cap 1.0), body *= 0.7
- Creamy/Syrupy selected → clarity -= 0.2 (floor 0.0), body += 0.3 (cap 1.0)

**Acidity Adjustment:**
- Bright/Juicy → acidity += 0.25 (cap 1.0)
- Smooth/Low → acidity -= 0.25 (floor 0.0)

**Sweetness Adjustment:**
- Sweet → sweetness += 0.3 (cap 1.0), bitterness focus = false
- Balanced → no adjustment
- Bitter → sweetness -= 0.2 (floor 0.0), boost recipes with roasty characteristics

### Method Capability Matrix

```swift
let methodCapabilities: [String: ExtractionCharacteristics] = [
    "V60": ExtractionCharacteristics(clarity: 0.9, acidity: 0.8, sweetness: 0.6, body: 0.3, ...),
    "AeroPress": ExtractionCharacteristics(clarity: 0.6, acidity: 0.7, sweetness: 0.7, body: 0.6, ...),
    "French Press": ExtractionCharacteristics(clarity: 0.2, acidity: 0.4, sweetness: 0.7, body: 0.9, ...),
    "Chemex": ExtractionCharacteristics(clarity: 0.95, acidity: 0.85, sweetness: 0.6, body: 0.2, ...)
]
```

### Required Localization Keys

```swift
// Preference Questionnaire
"preference_questionnaire_title"
"body_preference_question"
"body_light", "body_medium", "body_full"
"body_texture_question"
"body_texture_tea_like", "body_texture_creamy_syrupy"
"acidity_preference_question"
"acidity_bright_juicy", "acidity_smooth_low"
"acidity_hint"
"sweetness_preference_question"
"sweetness_sweet", "sweetness_balanced", "sweetness_bitter"
"recommendation_type_question"
"recommendation_type_general", "recommendation_type_method_specific"
"get_recommendations_button"
"skip_preferences_button"
// Recommendation Reasons
"matches_preference_body"
"matches_preference_acidity"
"matches_preference_sweetness"
"method_highlights_clarity"
"method_highlights_body"
```

### Navigation Flow Implementation

```swift
// CoffeeListView.swift
NavigationLink(destination: PreferenceQuestionnaireView(coffee: coffee)) {
    CoffeeRow(coffee: coffee) { ... }
}

// PreferenceQuestionnaireView.swift
@State private var preferences: UserTastePreferences?
@State private var showRecommendations = false

NavigationLink(
    destination: RecommendationsView(coffee: coffee, preferences: preferences),
    isActive: $showRecommendations
) { EmptyView() }
```

---

## ⚠️ Known Limitations & Edge Cases

1. **Incomplete Preferences**: If user skips questionnaire, preferences = nil, use default recommendations
2. **Method-Specific Filtering**: If no recipes match selected method, show empty state with message
3. **Preference Conflicts**: If user preferences conflict strongly with coffee characteristics, weighted blend ensures coffee profile still respected (70/30 split)
4. **Body Texture Optional**: Body texture question only shown if body preference is selected, otherwise skipped
5. **Method Highlighting Edge Cases**: If coffee has balanced characteristics (no clear dominant attribute), method highlighting bonus is smaller but still applied

---

## ✅ Ready for Implementation

This plan is ready for execution with:
- ✅ All file paths verified
- ✅ Architecture alignment confirmed
- ✅ State management patterns defined
- ✅ Error scenarios considered
- ✅ Preference adjustment formulas specified
- ✅ Method highlighting algorithm defined
- ✅ No placeholders or TODOs
- ✅ Follows PerfectBrew conventions

**Awaiting user approval before proceeding with implementation.**

