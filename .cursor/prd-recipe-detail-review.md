# PRD Review: Recipe Detail Overview Improvements

## 📊 Review Score: 7.5/10

### Context Check ✅
**Rating: 8/10**

Another LLM would have sufficient context to implement because:
- ✅ Problem clearly defined (user confusion about overview vs active brewing)
- ✅ Current structure documented (`BrewDetailScreen.swift` identified)
- ✅ User preferences noted (likes: parameters, notes; dislikes: weird scroll)
- ✅ Multiple solution options provided with specific implementation details
- ⚠️ Missing: Specific code snippets showing current vs proposed structure
- ⚠️ Missing: Detailed state management approach for expandable sections

### File Verification ✅
**Rating: 9/10**

Verified files exist:
- ✅ `PerfectBrew/BrewDetailScreen.swift` - Confirmed exists and reviewed
- ✅ `PerfectBrew/Services/LocalizationManager.swift` - Confirmed exists
- ✅ `PerfectBrew/BrewingGuideScreen.swift` - Confirmed (for comparison)
- ✅ Navigation flow understood (BrewDetailScreen → BrewingGuideScreen)

### PerfectBrew Consistency ✅
**Rating: 8/10**

Follows existing patterns:
- ✅ SwiftUI MVVM architecture maintained
- ✅ Uses existing `LocalizationManager` for strings
- ✅ Follows existing color scheme (orange primary, gray secondary)
- ✅ Consistent with `BrewingGuideScreen` design patterns
- ✅ Uses existing `AudioService` (already integrated)
- ⚠️ Missing: Specific examples of expandable card patterns used elsewhere
- ⚠️ Missing: State management pattern for expandable sections (@State vs ViewModel)

### Dependency Check ✅
**Rating: 10/10**

All dependencies available:
- ✅ `AudioService` - Already used in `BrewDetailScreen`
- ✅ `LocalizationManager` - Available and working
- ✅ `Recipe` model - Complete with all needed properties
- ✅ `BrewingStep` model - Available for step display
- ✅ Navigation to `BrewingGuideScreen` - Already implemented

### Error Scenarios ⚠️
**Rating: 6/10**

Gaps identified:
- ⚠️ **Missing**: Edge case handling for recipes with no steps
- ⚠️ **Missing**: Edge case handling for very long step descriptions
- ⚠️ **Missing**: What happens if user taps "View All Steps" multiple times?
- ⚠️ **Missing**: Handling for recipes with no preparation steps
- ⚠️ **Missing**: Accessibility considerations (VoiceOver, Dynamic Type)
- ✅ Covered: Basic user flow and transitions
- ✅ Covered: Visual distinction between overview and active brewing

### Audio Synchronization ✅
**Rating: 9/10**

Audio integration maintained:
- ✅ Notes audio already implemented and working
- ✅ No changes to audio file structure needed
- ✅ Audio service already integrated
- ✅ Step-to-audio mapping not affected (steps only shown as preview)

### Recipe Compatibility ✅
**Rating: 10/10**

JSON structure preserved:
- ✅ No changes to Recipe model required
- ✅ All existing recipe properties used as-is
- ✅ No breaking changes to recipe files

### Phase Breakdown ⚠️
**Rating: 7/10**

Current phases are high-level. Need more granular tasks:
- ⚠️ Phase 1 has 4 tasks (should be 3 per review rules)
- ⚠️ Phase 2 has 4 tasks (should be 3)
- ⚠️ Some tasks too broad (e.g., "Redesign steps section" needs breaking down)
- ⚠️ Missing: Testing tasks in each phase

---

## 🔄 Converted to Executable Format

### Phase 1: Visual Clarification & Overview Badge
- [ ] **Task 1**: Add overview badge header component above recipe title
  - Create reusable `OverviewBadgeView` component with icon and text
  - Add localization strings: "recipe_overview" and "review_before_brewing"
  - Position badge above recipe title in `BrewDetailScreen`
  
- [ ] **Task 2**: Update screen background color and visual styling
  - Change main `ScrollView` background to subtle gray (`Color(.systemGroupedBackground)`)
  - Ensure all cards maintain white background for contrast
  - Add section dividers between major sections (Parameters, Steps, Notes, Equipment)
  
- [ ] **Task 3**: Enhance "Start Brewing" button visual prominence
  - Increase button padding (.vertical: 20, .horizontal: 16)
  - Update button text to "Start Step-by-Step Brewing Guide"
  - Add subtitle text below button: "Follow guided steps with timer"
  - Add visual separator (Divider) above button

### Phase 2: Steps Section Redesign
- [ ] **Task 1**: Create expandable steps preview card component
  - Create `StepsPreviewCardView` component with collapsed/expanded states
  - Show condensed version: "X steps • Ys total" with first 2-3 steps preview
  - Add @State variable `isStepsExpanded: Bool` to manage expansion
  - Apply muted colors (gray.opacity(0.3) for step circles, secondary text color)
  
- [ ] **Task 2**: Replace current steps display with preview card
  - Remove individual step display loops for preparation and brewing steps
  - Replace with single `StepsPreviewCardView` component
  - Pass recipe steps as data source to component
  - Remove per-step time indicators, show only total time
  
- [ ] **Task 3**: Implement expand/collapse functionality
  - Add "View All X Steps" button that toggles `isStepsExpanded`
  - When expanded, show all steps in muted style (no timers, no interactive elements)
  - Add smooth animation for expand/collapse using `.animation(.easeInOut)`
  - Ensure expanded state scrolls smoothly within card

### Phase 3: Visual Refinement & Polish
- [ ] **Task 1**: Apply muted styling to all step-related elements
  - Change step circle backgrounds from Color.blue/Color.orange to Color.gray.opacity(0.3)
  - Update step text color to .secondary instead of .primary
  - Remove any interactive elements (buttons, taps) from step displays
  - Add "PREVIEW" text badge to steps section header
  
- [ ] **Task 2**: Add smooth animations and transitions
  - Animate overview badge appearance on screen load
  - Add smooth expand/collapse animations for steps card
  - Animate "Start Brewing" button state changes
  - Add scroll position indicators if content is long
  
- [ ] **Task 3**: Testing and edge case handling
  - Test with recipes that have no preparation steps
  - Test with recipes that have no brewing steps (edge case)
  - Test expand/collapse with very long step descriptions
  - Verify accessibility (VoiceOver labels, Dynamic Type support)
  - Test scroll behavior on different screen sizes (iPhone SE, Pro Max)

### Phase 4: Accessibility & Localization (Optional Enhancement)
- [ ] **Task 1**: Add accessibility labels and hints
  - Add `.accessibilityLabel("Recipe overview")` to overview badge
  - Add `.accessibilityHint("Review recipe details before brewing")` to steps section
  - Ensure button has clear accessibility label: "Start step-by-step brewing guide"
  
- [ ] **Task 2**: Add missing localization strings
  - Add "recipe_overview" key to LocalizationManager
  - Add "review_before_brewing" key
  - Add "start_step_by_step_guide" key
  - Add "view_all_steps" and "collapse_steps" keys
  - Add Spanish translations for all new strings
  
- [ ] **Task 3**: Test dynamic type and accessibility
  - Test with largest Dynamic Type setting
  - Verify VoiceOver navigation flows correctly
  - Test with reduced motion accessibility setting
  - Ensure color contrast meets WCAG standards

---

## 🚨 Critical Gaps to Address

### Before Implementation:

1. **State Management Clarification** ⚠️
   - Need to decide: Should expandable state be in @State or a ViewModel?
   - Recommendation: Use @State for simple expand/collapse (fits SwiftUI pattern)

2. **Edge Cases Missing** ⚠️
   - What if recipe has 0 preparation steps?
   - What if recipe has 0 brewing steps?
   - What if recipe has 20+ steps (scroll performance)?
   - Recommendation: Add conditional rendering with fallback UI

3. **Expandable Card Implementation** ⚠️
   - Need specific implementation pattern (DisclosureGroup vs custom)
   - Recommendation: Use native SwiftUI `DisclosureGroup` for consistency

4. **Button Positioning** ⚠️
   - Sticky button at bottom: Use `.safeAreaInset` or separate overlay?
   - Recommendation: Use `.safeAreaInset(edge: .bottom)` for native iOS feel

5. **Visual Distinction Metrics** ⚠️
   - How subtle should the gray background be?
   - What's the exact color value for "muted" steps?
   - Recommendation: Use system colors (`.systemGray6` background, `.secondary` text)

---

## ✅ Approval Checklist

- [ ] User approves selected solution approach (Card-based vs Timeline vs Badge-only)
- [ ] Edge cases addressed (empty steps, long descriptions)
- [ ] State management approach confirmed (@State for expandable)
- [ ] Button positioning approach confirmed (sticky vs static)
- [ ] Color values and visual styling specifications finalized
- [ ] Accessibility requirements confirmed
- [ ] Testing strategy approved

---

## 📝 Revised Score After Addressing Gaps: 9/10

With the executable format and addressing the critical gaps above, this PRD would be ready for implementation.

**Ready for User Approval**: Waiting for user to confirm approach and fill in missing specifications before proceeding.
