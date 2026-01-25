# PRD: Preference Questionnaire UX Improvements

## 📋 Summary

Redesign the preference questionnaire screen to be more intuitive, user-friendly, and follow iOS design best practices. The current implementation feels cluttered, has inconsistent layouts, and lacks clear visual hierarchy and progress indication.

## 🎯 Goals

1. **Improve Visual Hierarchy**: Clear progression through questions, less cognitive load
2. **Standard iOS Patterns**: Remove custom nav bar segmented controls, use standard iOS components
3. **Better Feedback**: Clear indication of progress and what's required
4. **Consistent Layout**: Unified chip/button design across all questions
5. **Progressive Disclosure**: Guide users through the flow naturally

## 🧪 Gherkin User Stories

### Story 1: Clear Progress Indication
```
Given I am on the preference questionnaire screen
When I view the screen
Then I should see a clear progress indicator showing which step I'm on (e.g., "Step 2 of 5")
And I should see which questions are required vs optional
```

### Story 2: Standard iOS Navigation
```
Given I am on the preference questionnaire screen
When I view the navigation bar
Then I should see a standard back button on the left
And I should see "Skip" as a standard button (not in a segmented control)
And the navigation should feel native to iOS
```

### Story 3: Clear Visual Feedback
```
Given I have not completed all required fields
When I view the "Get Recommendations" button
Then it should be visually distinct (e.g., faded but still visible)
And it should show a hint about what's missing (e.g., "Select body preference to continue")
When I complete all required fields
Then the button should become prominent and enabled
```

### Story 4: Consistent Question Layout
```
Given I am answering questions
When I view each question
Then all questions should use the same layout style
And chips should be consistently horizontal or vertical based on content
And spacing should be uniform throughout
```

### Story 5: Intuitive Question Flow
```
Given I am answering the body preference question
When I select "Light" body preference
Then the body texture question should appear smoothly (not suddenly)
And it should be clear that texture is optional
And the visual hierarchy should guide my eye naturally
```

## 🏗️ Functional Requirements

### FR1: Progress Indicator
- Display current step out of total (e.g., "2 of 5")
- Use a visual progress bar or dots at the top
- Update in real-time as user completes questions

### FR2: Standard Navigation
- Remove custom segmented control from nav bar
- Use standard iOS back button
- Place "Skip" as a toolbar button (left side)
- Remove duplicate "Get Recommendations" from toolbar (keep only in form)

### FR3: Smart Button States
- Primary CTA button should always be visible
- When incomplete: Show muted style with helpful text (e.g., "Select all preferences to continue")
- When complete: Show prominent orange button with "Get Recommendations"
- Provide visual feedback on what's missing (e.g., highlight incomplete sections)

### FR4: Consistent Chip Design
- All chips should use same styling
- Horizontal layout for 2-3 options (acidity, body texture)
- Horizontal layout for 3 options (body, recommendation type)
- Vertical stack for 3+ options only when horizontal doesn't fit (sweetness)
- Consistent padding, spacing, and corner radius

### FR5: Question Grouping
- Group related questions (body + body texture together)
- Use consistent section styling
- Add subtle dividers or spacing between question groups
- Make optional vs required clear with visual cues

### FR6: Conditional Questions
- Smooth animation when conditional questions appear
- Clear visual relationship to parent question
- Optional fields should be clearly marked

### FR7: Form Validation
- Visual feedback for required fields (not just disabled button)
- Subtle highlights or icons on incomplete sections
- Helpful error messages if user tries to proceed incomplete

## 🚫 Non-Goals

- Multi-step wizard (keep single scrollable form, but add progress indicator)
- Custom animations beyond standard SwiftUI transitions
- Changing data model or preferences structure
- Modifying recommendation logic (only UI/UX improvements)

## 📁 Affected Files

1. **`PerfectBrew/Views/MatchMyCoffee/PreferenceQuestionnaireView.swift`**
   - Complete redesign of layout and navigation
   - Add progress indicator component
   - Improve chip layout consistency
   - Enhance button states and feedback

2. **`PerfectBrew/Views/MatchMyCoffee/PreferenceChip.swift`** (or inline component)
   - Standardize chip styling
   - Ensure consistent sizing and spacing
   - Add accessibility labels

3. **`PerfectBrew/Services/LocalizationManager.swift`** (if needed)
   - Add new localization strings for progress indicator
   - Add button state messages

## 🎨 Design Improvements

### Layout Structure
```
┌─────────────────────────────┐
│ ← Back    Skip              │  Standard nav bar
├─────────────────────────────┤
│ ○ ○ ○ ○ ○                   │  Progress indicator (5 dots)
│   Step 2 of 5                │  Progress text
├─────────────────────────────┤
│                             │
│  WHAT BODY DO YOU PREFER?   │  Question header (larger, bolder)
│  ┌─────┐ ┌──────┐ ┌─────┐  │
│  │Light│ │Medium│ │Full │  │  Horizontal chips (equal width)
│  └─────┘ └──────┘ └─────┘  │
│                             │
│  [Optional]                 │  Optional label (subtle)
│  Body Texture               │  Sub-question header
│  ┌──────────┐ ┌──────────┐ │
│  │Tea-like  │ │Creamy/   │ │  Horizontal chips
│  │          │ │Syrupy    │ │
│  └──────────┘ └──────────┘ │
│                             │
│  ... (other questions)      │
│                             │
├─────────────────────────────┤
│  ┌────────────────────────┐ │
│  │ Get Recommendations    │ │  Primary CTA (always visible)
│  │ (or helpful hint)      │ │
│  └────────────────────────┘ │
└─────────────────────────────┘
```

### Key Changes
1. **Progress Indicator**: Visual dots + step counter at top
2. **Question Headers**: Larger, bolder, more prominent
3. **Chip Layout**: Consistent horizontal for most, vertical only when needed
4. **Spacing**: More generous whitespace between sections
5. **Button**: Always visible, smart states, helpful hints
6. **Optional Labels**: Clear indication of what's optional

## 🔧 Implementation Strategy

### Phase 1: Navigation & Progress
- [ ] Remove custom segmented control from nav bar
- [ ] Add standard back button and Skip toolbar item
- [ ] Implement progress indicator (dots + counter)
- [ ] Calculate and display current step

### Phase 2: Layout Consistency
- [ ] Standardize PreferenceChip component styling
- [ ] Unify horizontal chip layouts (use same HStack pattern)
- [ ] Fix vertical chip layout for sweetness (or make horizontal if fits)
- [ ] Ensure consistent spacing and padding

### Phase 3: Button States & Feedback
- [ ] Implement smart button states (incomplete vs complete)
- [ ] Add helpful hint text when incomplete
- [ ] Visual highlights for incomplete required sections
- [ ] Smooth transitions when requirements met

### Phase 4: Visual Polish
- [ ] Improve question header typography
- [ ] Add optional/required labels
- [ ] Smooth animations for conditional questions
- [ ] Consistent section dividers/spacing

## ✅ Success Metrics

1. **Usability**: Users can complete questionnaire in < 60 seconds
2. **Clarity**: 90%+ users understand all questions without confusion
3. **Completion Rate**: > 80% completion (vs current skip rate)
4. **Visual Consistency**: No layout inconsistencies between questions
5. **iOS Standards**: Follows iOS Human Interface Guidelines patterns

## 🧪 QA Strategy

### LLM Self-Test
- [ ] Verify all required fields are validated
- [ ] Test conditional question appearance/disappearance
- [ ] Verify navigation (back, skip, proceed)
- [ ] Check button states (incomplete → complete)
- [ ] Validate progress indicator accuracy
- [ ] Test on different screen sizes (iPhone SE, Pro Max)

### Manual User Verification
- [ ] User can intuitively complete all questions
- [ ] Progress feels natural and not overwhelming
- [ ] All interactions feel responsive and native
- [ ] Visual hierarchy guides eye naturally
- [ ] No confusion about optional vs required fields

## 🚀 Ready for Implementation

All components identified, design patterns defined, and implementation strategy clear. Ready to proceed with Phase 1.
