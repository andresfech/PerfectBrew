# PRD: Recipe Detail Screen - Overview/Preview UX Improvements

## 📋 Summary

Redesign the recipe detail screen (`BrewDetailScreen`) to make it **crystal clear** that this is an **overview/preview** screen, not the active brewing screen. Users are currently confused and think they should start brewing here. The goal is to help users familiarize themselves with the recipe before proceeding to the actual brewing guide.

## 🎯 Goals

1. **Clarify Purpose**: Make it super obvious this is a preview/overview, not active brewing
2. **Improve Visual Hierarchy**: Separate overview content from actionable brewing steps
3. **Better Scrolling Experience**: Fix the "weird" scroll feeling with preparation/brewing steps
4. **Maintain Liked Features**: Keep the parameter icons and notes section that users enjoy
5. **Clear Call-to-Action**: Make the transition to actual brewing unambiguous

## 🔍 Current Problems

### Problem 1: Confusion About Purpose
- **Issue**: Users think they start brewing here because they see brewing steps
- **Root Cause**: Steps displayed as if they're actionable, not informational
- **Impact**: Users try to interact with steps on overview screen

### Problem 2: Weird Scrolling Experience
- **Issue**: Second scroll (preparation/brewing steps section) feels awkward
- **Root Cause**: Steps are displayed in a way that suggests interactivity
- **Impact**: Poor UX, unclear what users should do with this information

### Problem 3: Unclear Visual Hierarchy
- **Issue**: Overview content mixed with step-by-step instructions
- **Root Cause**: Everything in one long scroll, no clear separation
- **Impact**: Users don't understand what's reference vs actionable

## 🧪 Gherkin User Stories

### Story 1: Clear Overview Purpose
```
Given I am viewing a recipe detail screen
When I see the screen for the first time
Then I should immediately understand this is a preview/overview
And I should see clear visual indicators that brewing hasn't started
And I should understand this helps me familiarize myself with the recipe
```

### Story 2: Better Steps Presentation
```
Given I am on the recipe detail overview screen
When I view the brewing steps section
Then I should see them presented as a preview/summary (not actionable)
And they should be visually distinct from the actual brewing screen steps
And scrolling through them should feel natural, not like I'm missing something
```

### Story 3: Clear Call-to-Action
```
Given I have reviewed the recipe overview
When I am ready to start brewing
Then I should see a prominent, clear button to "Start Brewing"
And this button should visually indicate it takes me to the active brewing screen
And the transition should be obvious and intentional
```

## 🏗️ Proposed Solutions

### Solution 1: Add Clear "Overview" Label & Badge
**Visual Changes:**
- Add a prominent badge/header at top: "📖 Recipe Overview" or "👀 Preview"
- Use subtle background tint (light gray) to distinguish from brewing screen
- Add a subtitle: "Review before brewing" or "Get familiar with the recipe"

**Implementation:**
- Add header section above title with overview badge
- Use different background color for entire screen (subtle gray vs white)
- Add informational icon (eye or document) to reinforce preview nature

### Solution 2: Redesign Steps Section - Make It Clearly Informational

**Option A: Collapsed/Card Summary** (Recommended)
- **Layout**: Show steps in a compact, card-based summary
- **Visual**: 
  - Single card titled "What You'll Do" or "Brewing Steps Preview"
  - Show first 2-3 steps as preview, with "View All X Steps" expandable
  - Use different visual style (subtle, muted) vs active brewing screen (bold, colorful)
  - Remove time indicators or show them as "Total: 170s" instead of per-step times
- **Scroll**: Remove the weird scroll by making it a single expandable card

**Option B: Timeline/Summary View**
- **Layout**: Show steps as a horizontal timeline or vertical summary list
- **Visual**:
  - Simplified icons (smaller, muted colors)
  - No time per step, just total time
  - Use "→" arrows or dots to show flow, not actionable buttons
  - Text: "You'll pour 30g → then 120g → then 200g" style summary
- **Scroll**: Horizontal swipeable cards or single vertical summary

**Option C: Step Count Badge Only**
- **Layout**: Don't show individual steps, just a summary
- **Visual**:
  - Badge: "5 Steps • 170s total"
  - Text: "View full step-by-step guide when you start brewing"
  - Remove the detailed steps list entirely
- **Scroll**: No scroll needed for steps (cleaner)

### Solution 3: Separate Sections with Clear Dividers

**Structure:**
```
┌─────────────────────────────┐
│ [OVERVIEW BADGE]            │
│ Recipe Overview             │
│ Review before brewing       │
├─────────────────────────────┤
│ 📊 BREW PARAMETERS          │ ← Keep as is (user likes)
│ [Parameter cards with icons]│
├─────────────────────────────┤
│ 📝 QUICK PREVIEW            │ ← New section header
│ What You'll Do:             │
│ [Condensed steps preview]   │ ← Redesigned
├─────────────────────────────┤
│ 📄 NOTES                    │ ← Keep as is (user likes)
│ [Notes with audio]          │
├─────────────────────────────┤
│ 🛠️ EQUIPMENT NEEDED         │
│ [Equipment list]            │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ ▶️ START BREWING        │ │ ← Prominent CTA
│ │ Begin step-by-step guide│ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

### Solution 4: Enhanced "Start Brewing" Button
**Visual Changes:**
- Make button more prominent (larger, centered, at bottom)
- Add icon and clear text: "▶️ Start Step-by-Step Brewing Guide"
- Add subtitle: "You'll follow guided steps with timer"
- Use sticky/fixed positioning at bottom if long content
- Add visual separator above button

**Behavior:**
- Button should feel like the main action
- Transition to BrewingGuideScreen should be clear
- Maybe add a confirmation or brief message about what happens next

### Solution 5: Add Visual Indicators That This Is NOT Active Brewing

**Visual Cues:**
1. **Background**: Subtle gray background for overview vs white for active brewing
2. **Icons**: Use "eye" or "document" icons, not "play" icons for steps
3. **Typography**: Use lighter, less prominent fonts for steps (vs bold in brewing screen)
4. **Colors**: Muted colors for steps (gray/blue) vs vibrant (orange/active) in brewing screen
5. **Interaction**: No tapable/interactive elements in steps (remove any buttons)
6. **Badge**: Add "PREVIEW" or "OVERVIEW" badge in header

### Solution 6: Improve Scrolling Experience

**For Steps Section:**
- **Option A**: Use a single expandable card (no weird scroll)
- **Option B**: Use horizontal swipeable cards (more natural)
- **Option C**: Remove detailed steps, show only summary count
- **Option D**: Use a bottom sheet/modal for full steps (tap to expand)

**Overall Scrolling:**
- Add smooth scrolling indicators
- Use section dividers for better visual breaks
- Add "Back to Top" button if content is long
- Consider tabs: "Overview" | "Full Steps" (optional)

## 📊 Recommended Approach (Combination)

### Primary Solution: Card-Based Summary + Clear Visual Distinction

1. **Add Overview Badge** (Solution 1)
   - Header: "📖 Recipe Overview - Review Before Brewing"

2. **Redesign Steps Section** (Solution 2, Option A)
   - Single card titled "Brewing Steps Preview"
   - Show condensed version: "5 steps • 170s total"
   - Expandable "View All Steps" button
   - Muted colors, different style from active brewing screen
   - Remove per-step timers, show only total time

3. **Enhanced CTA Button** (Solution 4)
   - Large, prominent button at bottom
   - Text: "▶️ Start Step-by-Step Brewing Guide"
   - Sticky positioning if content scrolls

4. **Visual Indicators** (Solution 5)
   - Subtle gray background
   - Muted colors for steps
   - No interactive elements in steps

5. **Better Section Dividers** (Solution 3)
   - Clear section headers
   - Visual separators between sections

## 🚫 Non-Goals

- Don't remove the parameters section (user likes it)
- Don't remove the notes section (user likes it)
- Don't add complex step-by-step interaction in overview
- Don't make it too cluttered with badges and labels

## 📁 Affected Files

1. **`PerfectBrew/BrewDetailScreen.swift`**
   - Add overview badge/header
   - Redesign steps section (card-based, expandable)
   - Enhance "Start Brewing" button
   - Update visual styling (background, colors)
   - Add section dividers

2. **`PerfectBrew/Services/LocalizationManager.swift`** (if needed)
   - Add strings for "Recipe Overview", "Preview", "Start Step-by-Step Guide", etc.

## ✅ Success Metrics

1. **Clarity**: 90%+ users understand this is overview without trying to interact with steps
2. **Completion**: Users review overview then successfully transition to brewing screen
3. **Satisfaction**: No confusion about when brewing actually starts
4. **Scroll Experience**: Users don't report "weird" scroll feeling

## 🧪 QA Strategy

### LLM Self-Test
- [ ] Verify overview badge/header is prominent
- [ ] Check steps section is clearly informational (not actionable)
- [ ] Verify "Start Brewing" button is prominent and clear
- [ ] Test expandable steps card (if implemented)
- [ ] Check visual distinction from active brewing screen
- [ ] Verify scrolling feels natural

### Manual User Verification
- [ ] Users immediately understand this is a preview
- [ ] Users don't try to interact with steps in overview
- [ ] Steps scrolling feels natural (not weird)
- [ ] Clear transition to actual brewing screen
- [ ] Users can easily review all information before brewing

## 🚀 Implementation Phases

### Phase 1: Visual Clarification (High Priority)
- [ ] Add overview badge/header
- [ ] Change background color (subtle gray)
- [ ] Update "Start Brewing" button styling
- [ ] Add visual separators

### Phase 2: Steps Section Redesign (High Priority)
- [ ] Convert steps to condensed card/preview
- [ ] Remove per-step timers (show total only)
- [ ] Add expandable "View All" functionality
- [ ] Apply muted styling

### Phase 3: Polish & Refinement (Medium Priority)
- [ ] Add smooth animations
- [ ] Optimize scrolling experience
- [ ] Add accessibility labels
- [ ] Fine-tune spacing and typography

---

## 🎯 Key Design Principles

1. **Preview ≠ Active**: Overview should look and feel different from active brewing
2. **Information vs Action**: Steps are informational here, actionable in brewing screen
3. **Clear Hierarchy**: Most important info (parameters) at top, action (button) at bottom
4. **Progressive Disclosure**: Show summary first, details on demand
5. **No False Affordances**: Don't make steps look interactive if they're not

---

**Ready for Review**: This plan provides specific, actionable improvements that address user confusion while maintaining features they like. Implementation can be phased for iterative improvement.
