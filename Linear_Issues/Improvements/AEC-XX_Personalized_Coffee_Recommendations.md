# PRD: Personalized Coffee Recommendations with User Preferences

## 📋 Summary

Add a preference questionnaire screen before showing coffee recipe recommendations. The system will ask users about their taste preferences (body, acidity, sweetness/bitterness) and recommendation type (general vs method-specific), then adjust recommendations based on both the coffee's characteristics and the user's personal taste profile.

## 🎯 Goals

**Primary Goal**: Provide personalized recipe recommendations that align with user taste preferences while highlighting the coffee's best attributes through optimal brewing methods.

**How**: 
- Create a preference questionnaire screen that appears after coffee selection
- Collect user preferences for body (light/medium/full, tea-like vs creamy/syrupy), acidity (bright/juicy vs smooth/low), and sweetness/bitterness balance
- Allow users to choose between general recommendations or method-specific recommendations
- Adjust recommendation scoring algorithm to incorporate user preferences
- Modify target extraction characteristics based on user preferences while preserving coffee's inherent qualities
- Store user preferences (optional: per coffee or global)

## 🧪 Gherkin User Stories

### Story 1: Preference Questionnaire Flow
```
Feature: Show preference questionnaire before recommendations

Given I have selected a coffee from "My Coffees" list
When I tap on the coffee to see recommendations
Then I see a preference questionnaire screen with:
  - Question: "What body do you prefer?"
  - Options: Light / Medium / Full
  - Follow-up: "Do you prefer tea-like or creamy/syrupy texture?"
  - Question: "What acidity level do you enjoy?"
  - Options: Bright/Juicy (high acidity) / Smooth/Low (low acidity)
  - Context: "Fruity coffees are usually higher in acidity, chocolatey/nutty are usually lower"
  - Question: "Sweetness or Bitterness preference?"
  - Options: Sweet (chocolate/caramel notes) / Balanced / Bitter (roasty flavors)
  - Question: "Recommendation type?"
  - Options: General (all methods) / Method-specific (choose brewing method)
And I can answer all questions and tap "Get Recommendations"
Then the app shows recommendations adjusted to my preferences
And recommendations consider how to highlight the coffee with the chosen method
```

### Story 2: General Recommendations
```
Feature: Get general recommendations based on preferences

Given I have completed the preference questionnaire
And I selected "General" recommendation type
When the recommendations are calculated
Then I see recommendations from all brewing methods (V60, AeroPress, French Press, Chemex)
And recommendations are ranked by:
  - Match to coffee's optimal extraction characteristics
  - Alignment with my personal taste preferences
  - Method's ability to highlight the coffee's best attributes
And each recommendation shows a match score and reasons
```

### Story 3: Method-Specific Recommendations
```
Feature: Get recommendations for specific brewing method

Given I have completed the preference questionnaire
And I selected "Method-specific" recommendation type
And I chose "V60" as my preferred method
When the recommendations are calculated
Then I see only V60 recipe recommendations
And recommendations are ranked by:
  - How well the V60 method can highlight the coffee's characteristics
  - Alignment with my taste preferences within V60's capabilities
  - Recipe's ability to adapt to my preferred body/acidity/sweetness
And recommendations explain why these V60 recipes work for my preferences
```

### Story 4: Preference-Based Scoring Adjustment
```
Feature: Adjust recommendations based on user preferences

Given the system has calculated base recommendations for a coffee
And the user prefers:
  - Body: Full, Creamy/Syrupy
  - Acidity: Smooth/Low
  - Sweetness: Sweet (chocolate/caramel)
When preferences are applied to recommendation scoring
Then recipes with higher body scores get boosted
And recipes that emphasize creamy/syrupy texture get prioritized
And recipes with lower acidity profiles get boosted
And recipes that highlight sweetness and chocolate notes get prioritized
And recipes with high bitterness/roasty profiles get deprioritized
And the final ranking reflects both coffee characteristics and user preferences
```

### Story 5: Coffee Highlighting Logic
```
Feature: Recommend methods that highlight coffee's best attributes

Given a coffee has specific characteristics (e.g., Light roast, Ethiopian, Fruity)
And the user has specified preferences (e.g., prefers brightness and clarity)
When generating recommendations
Then the system considers:
  - Which brewing methods best highlight fruity, bright notes (e.g., V60 for clarity)
  - How the user's preferences align with the coffee's natural profile
  - Whether to recommend methods that complement or enhance the coffee
And recommendations explain why the method highlights the coffee well
```

### Story 6: Skip Preferences (Optional)
```
Feature: Skip preference questionnaire for quick recommendations

Given I am viewing the preference questionnaire
When I tap "Skip, show general recommendations"
Then I see standard recommendations without personalization
And recommendations are based solely on coffee characteristics
And I can complete preferences later if desired
```

## 📦 Functional Requirements

### FR1: Preference Questionnaire UI
- **FR1.1**: Create `PreferenceQuestionnaireView` screen
- **FR1.2**: Display body preference question with Light/Medium/Full options
- **FR1.3**: Display body texture follow-up: "Tea-like" vs "Creamy/Syrupy"
- **FR1.4**: Display acidity preference with Bright/Juicy vs Smooth/Low options
- **FR1.5**: Show contextual hint: "Fruity coffees are usually higher in acidity, chocolatey/nutty are usually lower"
- **FR1.6**: Display sweetness/bitterness preference: Sweet (chocolate/caramel) / Balanced / Bitter (roasty)
- **FR1.7**: Display recommendation type selector: General vs Method-specific
- **FR1.8**: If Method-specific selected, show brewing method picker (V60, AeroPress, French Press, Chemex)
- **FR1.9**: Include "Skip" option to use default recommendations

### FR2: User Preferences Model
- **FR2.1**: Create `UserTastePreferences` struct with:
  - `bodyPreference: BodyPreference` (light/medium/full)
  - `bodyTexture: BodyTexture` (teaLike/creamySyrupy)
  - `acidityPreference: AcidityPreference` (brightJuicy/smoothLow)
  - `sweetnessPreference: SweetnessPreference` (sweet/balanced/bitter)
  - `recommendationType: RecommendationType` (general/methodSpecific)
  - `selectedMethod: String?` (if methodSpecific)
- **FR2.2**: Store preferences temporarily for the recommendation session
- **FR2.3**: (Optional) Persist preferences globally or per-coffee for future use

### FR3: Preference-Based Recommendation Algorithm
- **FR3.1**: Modify `RecommendationService.calculateScore()` to accept `UserTastePreferences`
- **FR3.2**: Calculate base score using existing coffee-to-recipe matching
- **FR3.3**: Apply preference adjustments to scoring:
  - Body preference adjustment: Boost recipes that match preferred body level
  - Body texture adjustment: Boost tea-like recipes if tea-like preferred, creamy/syrupy if preferred
  - Acidity adjustment: Boost recipes with matching acidity profiles
  - Sweetness/bitterness adjustment: Boost recipes aligned with preference
- **FR3.4**: Combine coffee characteristics score (60%) with preference alignment (40%)
- **FR3.5**: For method-specific recommendations, filter recipes by selected method before scoring

### FR4: Target Profile Modification
- **FR4.1**: Create `adjustTargetProfile()` method in `RecommendationService`
- **FR4.2**: Take base target profile from `BrewingRuleEngine.computeTargetProfile(for: coffee)`
- **FR4.3**: Adjust target profile based on user preferences:
  - Body: Adjust target body value toward user preference (light=0.3, medium=0.5, full=0.7)
  - Body texture: Adjust clarity (tea-like=higher clarity, creamy=lower clarity)
  - Acidity: Adjust target acidity toward preference (bright=higher, smooth=lower)
  - Sweetness: Adjust target sweetness (sweet=higher, bitter=lower)
- **FR4.4**: Ensure adjustments don't completely override coffee's inherent characteristics (use weighted blend)
- **FR4.5**: Keep physical constraints (agitation, thermal) from coffee profile

### FR5: Method Highlighting Logic
- **FR5.1**: Add `methodHighlightScore()` helper to evaluate how well a method highlights coffee
- **FR5.2**: Consider method characteristics:
  - V60: High clarity, brightness, clean finish (good for fruity, light roasts)
  - AeroPress: Versatile, can emphasize body or clarity depending on technique
  - French Press: Full body, low clarity (good for body-forward coffees)
  - Chemex: Very clean, bright, tea-like (similar to V60 but more filtered)
- **FR5.3**: Boost recommendations where method characteristics align with coffee's best attributes
- **FR5.4**: Boost recommendations where method characteristics align with user preferences
- **FR5.5**: Add reason tags like "Highlights coffee's brightness" or "Emphasizes body"

### FR6: Recommendation Display
- **FR6.1**: Update recommendation reasons to mention preference alignment
- **FR6.2**: Show why the recipe matches user preferences (e.g., "Matches your preference for full body")
- **FR6.3**: Show how the method highlights the coffee (e.g., "V60 highlights fruity notes")
- **FR6.4**: Display adjusted match scores that reflect both coffee match and preference alignment

## 🚫 Non-Goals (Scope Boundaries)

- **NG1**: Learning user preferences over time from brew history (separate ML feature)
- **NG2**: Multiple preference profiles for different contexts (e.g., morning vs evening)
- **NG3**: Detailed flavor wheel selection (keep it simple with 3 main dimensions)
- **NG4**: Preference-based recipe parameter adjustments (only recipe selection, not recipe modification)
- **NG5**: Social features (sharing preferences, comparing with others)
- **NG6**: Preference recommendations based on similar users (no user matching)
- **NG7**: Complex preference profiles (keep questionnaire to 3-4 simple questions)

## 📁 Affected Files

### New Files
- `PerfectBrew/Models/UserTastePreferences.swift` - User preference model
- `PerfectBrew/Views/MatchMyCoffee/PreferenceQuestionnaireView.swift` - Preference questionnaire UI

### Modified Files
- `PerfectBrew/ViewModels/RecommendationsViewModel.swift` - Add preferences handling, modify load flow
- `PerfectBrew/Services/RecommendationService.swift` - Add preference-based scoring, target profile adjustment
- `PerfectBrew/Views/MatchMyCoffee/RecommendationsView.swift` - Handle preference flow, show preference-adjusted recommendations
- `PerfectBrew/Views/MatchMyCoffee/CoffeeListView.swift` - Navigate to questionnaire instead of directly to recommendations
- `PerfectBrew/Services/LocalizationManager.swift` - Add preference-related strings (English and Spanish)

## 🔍 Investigation Needed

### I1: Preference Weighting Strategy
- **Question**: How much should user preferences influence recommendations vs coffee characteristics?
- **Approach**: Test different weighting ratios (50/50, 60/40, 70/30) to find balance
- **Decision**: Use 60% coffee characteristics, 40% preferences (coffee quality shouldn't be overridden, but preferences guide selection)

### I2: Body Texture Mapping
- **Question**: How to map "tea-like" vs "creamy/syrupy" to ExtractionCharacteristics?
- **Approach**: Tea-like = higher clarity (0.7-1.0), Creamy/Syrupy = lower clarity, higher body (0.3-0.5 clarity, 0.6-1.0 body)
- **Decision**: Use clarity dimension as proxy for tea-like vs creamy texture

### I3: Acidity Preference Impact
- **Question**: How to adjust target acidity when user prefers bright vs smooth?
- **Approach**: Bright preference = add 0.2-0.3 to target acidity (capped at 1.0), Smooth preference = subtract 0.2-0.3 (floored at 0.0)
- **Decision**: Apply moderate adjustment (±0.25) to respect coffee's inherent acidity while accommodating preference

### I4: Method Highlighting Scoring
- **Question**: How to score how well a method highlights a coffee's attributes?
- **Approach**: Create method capability matrix (method × attribute), use coffee's dominant attributes to score methods
- **Decision**: Use predefined method profiles and match against coffee's primary characteristics (fruity→V60/Chemex, body→FrenchPress, versatile→AeroPress)

### I5: Preference Persistence
- **Question**: Should preferences be saved globally or per-coffee?
- **Approach**: Start with session-only preferences, add persistence later if users request it
- **Decision**: Session-only for MVP, add persistence in future iteration if needed

## 🗄️ Data Schema

### New Models
```swift
enum BodyPreference: String, CaseIterable, Codable {
    case light, medium, full
}

enum BodyTexture: String, CaseIterable, Codable {
    case teaLike, creamySyrupy
}

enum AcidityPreference: String, CaseIterable, Codable {
    case brightJuicy, smoothLow
}

enum SweetnessPreference: String, CaseIterable, Codable {
    case sweet, balanced, bitter
}

enum RecommendationType: String, CaseIterable, Codable {
    case general, methodSpecific
}

struct UserTastePreferences: Codable {
    var bodyPreference: BodyPreference
    var bodyTexture: BodyTexture?
    var acidityPreference: AcidityPreference
    var sweetnessPreference: SweetnessPreference
    var recommendationType: RecommendationType
    var selectedMethod: String? // Brewing method if methodSpecific
}
```

**No database changes required** - Preferences stored in-memory for recommendation session only (future: could be stored in UserDefaults or CoreData)

## 🎨 Design/UI

### UI Flow
1. **CoffeeListView**: User taps coffee → Navigate to PreferenceQuestionnaireView
2. **PreferenceQuestionnaireView**: Multi-step questionnaire with clear sections:
   - Body preference (Light/Medium/Full chips)
   - Body texture (Tea-like vs Creamy/Syrupy) - shown conditionally
   - Acidity preference (Bright/Juicy vs Smooth/Low with context hint)
   - Sweetness preference (Sweet/Balanced/Bitter)
   - Recommendation type (General vs Method-specific toggle)
   - Method picker (if method-specific selected)
   - "Get Recommendations" button (disabled until required fields completed)
   - "Skip" button (show default recommendations)
3. **RecommendationsView**: Show preference-adjusted recommendations with updated reasons

### Visual Design
- Use chip/button selection pattern (similar to existing filter chips in RecipeSelectionScreen)
- Orange accent color for selected options (consistent with app theme)
- Clear section headers with explanatory text
- Progress indicator or section numbers to show questionnaire progress
- Contextual hints in smaller, secondary text color

## ⚙️ State Management

### ViewModel State
```swift
@Published var preferences: UserTastePreferences?
@Published var isQuestionnaireComplete: Bool = false
@Published var showingQuestionnaire: Bool = true
```

### Navigation Flow
- CoffeeListView → PreferenceQuestionnaireView → RecommendationsView
- Use NavigationLink or programmatic navigation based on questionnaire completion

## 🔐 Permissions Required

None - no new permissions needed

## 📊 Success Metrics

1. **User Engagement**: % of users who complete preference questionnaire vs skip
2. **Recommendation Relevance**: % of users who select recommended recipes (track in brew history)
3. **Preference Impact**: Average score difference between preference-adjusted and default recommendations
4. **User Satisfaction**: User feedback on recommendation quality (qualitative)
5. **Method Selection**: Distribution of general vs method-specific recommendation choices

## 🔄 Git Strategy

### Branch Naming
- Feature branch: `feature/personalized-recommendations`

### Commit Checkpoints
1. **Models**: Create UserTastePreferences model and enums
2. **Questionnaire UI**: Build PreferenceQuestionnaireView with all questions
3. **Navigation Flow**: Integrate questionnaire into coffee selection flow
4. **Preference Scoring**: Add preference-based adjustments to RecommendationService
5. **Target Profile Adjustment**: Implement adjustTargetProfile() method
6. **Method Highlighting**: Add method highlighting logic and scoring
7. **Recommendation Display**: Update recommendation reasons to show preference alignment
8. **Localization**: Add Spanish translations for preference strings
9. **Testing**: QA and refinement

## ✅ QA Strategy

### LLM Self-Test
- [ ] Verify preference model correctly encodes all preference types
- [ ] Test preference scoring adjustments don't break existing recommendation logic
- [ ] Validate target profile adjustments respect coffee characteristics
- [ ] Check method highlighting logic correctly identifies best methods
- [ ] Verify navigation flow works correctly (questionnaire → recommendations)

### Manual User Verification
- [ ] Complete preference questionnaire with various combinations
- [ ] Compare recommendations with preferences vs without preferences
- [ ] Test general recommendations show recipes from all methods
- [ ] Test method-specific recommendations only show selected method
- [ ] Verify preference explanations appear in recommendation reasons
- [ ] Test skip functionality shows default recommendations
- [ ] Verify UI works in both English and Spanish
- [ ] Test on different device sizes (iPhone, iPad)

## 🚀 Implementation Phases

### Phase 1: Models & Basic UI (Week 1)
- Create UserTastePreferences model and enums
- Build basic PreferenceQuestionnaireView with all questions
- Add localization strings

### Phase 2: Navigation & Flow (Week 1)
- Integrate questionnaire into CoffeeListView navigation
- Handle questionnaire completion → RecommendationsView transition
- Implement skip functionality

### Phase 3: Preference-Based Scoring (Week 1-2)
- Modify RecommendationService to accept preferences
- Implement preference adjustments to scoring algorithm
- Add preference alignment to recommendation reasons

### Phase 4: Target Profile Adjustment (Week 2)
- Implement adjustTargetProfile() method
- Blend user preferences with coffee characteristics
- Test profile adjustments don't override critical coffee attributes

### Phase 5: Method Highlighting (Week 2)
- Create method capability profiles
- Implement method highlighting scoring
- Add method-specific recommendation reasons

### Phase 6: Polish & Testing (Week 2-3)
- Refine UI/UX based on testing
- Add contextual help text and hints
- QA testing and bug fixes

---

## 📝 Notes

- Preferences are session-only for MVP to keep scope manageable
- Recommendation scoring uses weighted combination: 60% coffee match, 40% preference alignment
- Method highlighting considers both coffee characteristics and user preferences
- Tea-like vs Creamy/Syrupy maps to clarity dimension in ExtractionCharacteristics
- Can be extended later to persist preferences, learn from history, or support multiple profiles

