# PRD: Exertion-Style Taste Feedback UI

**Status**: Draft  
**Reference**: The Outsiders — Perceived Exertion UI (Mobbin)  
**Scope**: Replace current `TasteDimensionSlider` (slider + expected band + pill) with a full exertion-style UI: gradient bar, hatched “expected range,” custom scrubber, pill above bar, big number + descriptor + explanation, Clear / How-to / Save / Dismiss. **Taste Profile presented in a modal** (card + blurred background).

---

## 1. Summary

**Goal**: Implement a Perceived Exertion–style taste feedback UI so users rate sweetness, bitterness, and acidity on a continuous 0–1 scale with (a) a gradient track, (b) a visually distinct “expected for this coffee” range (hatched overlay), (c) a custom draggable scrubber, (d) a dynamic pill above the bar (Below / Within / Above expected), and (e) a large numeric display plus descriptor and short explanation. **Taste Profile is presented in a modal** (floating card + blurred background) with Clear Entry, How to Self-Assess, Save (with subtitle), and Dismiss.

**Out of scope**: Changing diagnostic logic (`ActualTasteProfile`, `SmartDiagnosticService`), recipe/audio, or brew history storage. Data remains 0–1 continuous; only the **input UI** is redesigned.

---

## 2. Gherkin User Stories

### US1: Gradient bar + expected range + scrubber
- **Given** I am on the Feedback screen, Taste Profile section, with a coffee selected  
- **When** I view a taste dimension (e.g. Sweetness)  
- **Then** I see a horizontal gradient bar (e.g. low→high), an “expected for this coffee” segment with diagonal hash overlay, and a draggable scrubber I can move along the bar  
- **And** the scrubber position maps to a value 0–1 stored in `FeedbackData`

### US2: Big number + descriptor + explanation
- **Given** I am rating a taste dimension  
- **When** I move the scrubber (or have a default value)  
- **Then** I see a large numeric display (e.g. 0–1 scaled to 1–10 or shown as %), a bold descriptor (e.g. “Within expected,” “A bit low”), and a short explanation (e.g. “Matches what this coffee typically delivers”)  
- **And** descriptor and explanation update as I move the scrubber

### US3: Pill above bar
- **Given** I am rating a taste dimension with an expected range  
- **When** my scrubber position is below / within / above the expected range  
- **Then** I see a pill **above** the bar, centered on the scrubber, labeled “Below expected” / “Within expected” / “Above expected”  
- **And** pill color reflects state (e.g. green within, orange outside)

### US4: No expected (no coffee)
- **Given** I am on Taste Profile and no coffee is selected  
- **When** I view a taste dimension  
- **Then** I see the gradient bar and scrubber **without** an expected-range overlay  
- **And** the pill shows “Low” / “Medium” / “High” based on value only

### US5: Clear, How-to, Save, Dismiss (modal)
- **Given** the taste UI is presented in a **modal** (floating card, blurred background)  
- **When** I tap “Clear Entry”  
- **Then** the current dimension’s value resets to a neutral default (e.g. 0.5)  
- **When** I tap “How to Self-Assess >”  
- **Then** I navigate to a short guidance screen (or inline expand) on how to rate taste  
- **When** I tap “Save”  
- **Then** my taste ratings are committed and the modal dismisses  
- **And** the Save button shows a subtitle reflecting current state (e.g. “Within expected” / “Above expected”)  
- **When** I tap “Dismiss”  
- **Then** the modal dismisses without saving

### US6: Accessibility
- **Given** I use VoiceOver  
- **When** I focus the custom gradient bar + scrubber  
- **Then** I hear an appropriate `accessibilityLabel`, `accessibilityValue` (e.g. “Sweetness, Within expected”), and `accessibilityHint`  
- **And** I can adjust the value via `accessibilityAdjustableAction` (increment/decrement)  
- **And** all new buttons (Clear, How-to, Save, Dismiss) have `accessibilityLabel` (and hint where useful)

### US7: Localization & UX consistency
- **Given** the app language is Spanish (or other supported locale)  
- **When** I view the exertion-style taste UI  
- **Then** all new strings (descriptors, explanations, Clear, How-to, Save subtitle, etc.) use `.localized`  
- **And** layout respects 8pt grid, 44pt min touch targets, and PerfectBrew accent (`.orange`) for primary actions

---

## 3. Functional Requirements

| ID | Requirement | Validation |
|----|-------------|------------|
| FR1 | Gradient bar replaces current gray track; full-width, rounded, `LinearGradient` (e.g. low→high palette). | Visual check. |
| FR2 | “Expected” range: segment overlay with diagonal hash pattern (custom `Shape`/`Path`) when `expected != nil`; label “Expected for this coffee” below segment. | Visual check; no overlay when no coffee. |
| FR3 | Custom scrubber: draggable `Circle` (e.g. white ring + colored fill), `DragGesture` + `GeometryReader`; position = `barWidth * (value - 0) / 1`. | Drag updates `value`; no standard `Slider`. |
| FR4 | Pill above bar: `Capsule` with dynamic text (Below/Within/Above or Low/Medium/High), centered on scrubber x; color by state. | Visual check; updates with value. |
| FR5 | Big number + descriptor + explanation: derived from value (and expected range if present); mapping configurable (e.g. 0–1 → 1–10 display, descriptor table). | Copy updates when value changes. |
| FR6 | Clear Entry: resets current dimension to default (e.g. 0.5). | Tap clears; value updates. |
| FR7 | How to Self-Assess: navigates to guidance or expands inline. | Navigation or expand works. |
| FR8 | Save: primary orange button, subtitle from current state; on tap, persist and **dismiss modal**. | Save commits; modal dismisses; subtitle correct. |
| FR9 | Dismiss: secondary text-only button; **dismiss modal** without saving. | Dismiss closes modal; no save. |
| FR10 | `FeedbackData` still stores 0–1 for sweetness/bitterness/acidity; `ActualTasteProfile.from` and diagnostics unchanged. | Unit/test: same outputs for same inputs. |
| FR11 | All new UI strings localized (EN + ES); use `.localized`. | LocalizationManager keys; switch language. |
| FR12 | `accessibilityLabel`, `accessibilityValue`, `accessibilityHint`, `accessibilityAdjustableAction` on custom bar; labels on new buttons. | VoiceOver test. |

---

## 4. Non-Goals

- **No diagnostic changes**: `SmartDiagnosticService`, `BrewingDiagnostics.json`, `ActualTasteProfile` logic unchanged.  
- **No recipe/audio changes**: Recipe JSON, audio paths, step-to-audio mapping unchanged.  
- **No schema changes**: Brew history, `FeedbackData`, `Brew` structure unchanged; only UI and interaction.  
- **No backend**: All logic remains local (no new APIs).  
- **Modal required**: Taste Profile is **always** presented in a modal (card + blurred background); no inline-only variant.

---

## 5. Affected Files

| File | Change |
|------|--------|
| `PerfectBrew/FeedbackScreen.swift` | Replace inline Taste Profile with **modal** entry point; present `ExertionStyleTasteModal` (card + blur). On Save, persist taste data and dismiss. |
| `PerfectBrew/Services/LocalizationManager.swift` | Add keys for new copy (descriptors, explanations, Clear, How-to, Save subtitle, etc.) EN + ES. |
| **New** `PerfectBrew/Views/Taste/ExertionStyleTasteView.swift` (or equivalent) | New view: gradient bar, hatched range, scrubber, pill, big number + descriptor + explanation. Host Clear / How-to; used **inside** modal. |
| **New** `PerfectBrew/Views/Taste/ExertionStyleTasteModal.swift` (or equivalent) | Modal container: blurred background, dark card, Save (orange + subtitle) + Dismiss. Wraps `ExertionStyleTasteView`; persists on Save, dismisses on Save/Dismiss. |
| **New** `PerfectBrew/Views/Taste/TasteDescriptorMap.swift` (or shared config) | Value → (descriptor, explanation) mapping; reuse for all three dimensions with dimension-specific copy. |
| `PerfectBrew/BrewHistoryScreen.swift` | No change to `comparativeLabel` or display; still consumes `FeedbackData` 0–1. |
| `PerfectBrew/Models/BrewRecommendation.swift` | No change to `ActualTasteProfile.from`. |
| `PerfectBrew/Services/SmartDiagnosticService.swift` | No change. |

---

## 6. Git Strategy

- **Branch**: `feature/exertion-style-taste-ui`  
- **Checkpoints**:  
  1. Add `ExertionStyleTasteView` + gradient bar + scrubber + pill (no modal).  
  2. Add expected-range overlay + hatched segment + descriptor map.  
  3. Add big number + descriptor + explanation.  
  4. Add **modal** (`ExertionStyleTasteModal`): card + blur, Clear / How-to / Save / Dismiss; localization; a11y.  
- **Merge**: After QA sign-off, merge to `main`.

---

## 7. QA Strategy

- **LLM self-test**: Run UX checklist (navigation, layout, contrast, a11y); verify Gherkin scenarios; confirm no references to mocks/placeholders.  
- **Manual**:  
  - Device: iPhone 16 Pro (or current target), iOS 18.  
  - Flows: Feedback → Taste Profile with/without coffee; drag scrubber; Clear; How-to; Save; Dismiss.  
  - VoiceOver: Focus bar, adjust value, activate all buttons.  
  - Localization: EN ↔ ES; check new strings.  
- **Regression**: Submit feedback → Recommendations; Brew History detail; confirm diagnostics unchanged for same inputs.

---

## 8. Success Metrics

- All Gherkin scenarios pass.  
- All FR1–FR12 validated.  
- No regressions in diagnostic or brew history behavior.  
- VoiceOver and 44pt touch targets satisfied for new UI.

---

## 9. UX Checklist (from UX Skill)

- [ ] Navigation clear; back/dismiss works.  
- [ ] 8pt grid; 44pt min touch targets; safe areas.  
- [ ] Accent `.orange` for primary actions; WCAG AA contrast.  
- [ ] Dark mode supported.  
- [ ] All new strings localized.  
- [ ] `accessibilityLabel` / `accessibilityValue` / `accessibilityHint` / `accessibilityAdjustableAction` where required.

---

## 10. Risks & Open Points

- **Custom scrubber**: More gesture + layout logic than `Slider`; needs careful testing across devices.  
- **Descriptor map**: Content design (descriptor + explanation per value band) to be defined; can start with minimal set and iterate.  
- **Modal**: **Decided.** Taste Profile is always presented in a modal (card + blur, Save / Dismiss).

---

# PRD Review (per 03-prd-review)

## Context Check

Another LLM can implement this with: (1) this PRD, (2) `FeedbackScreen.swift` and `TasteDimensionSlider` current implementation, (3) `LocalizationManager` pattern, (4) UX skill (accessibility, PerfectBrew patterns). No prior exertion-UI context required; reference image description is summarized in the PRD.

## Completeness Score: **7.5 / 10**

| Gap | Impact |
|-----|--------|
| Descriptor + explanation **content** not specified (exact strings per value band) | Medium — implementation will need copy; can start with placeholders and iterate. |
| "How to Self-Assess" destination (new screen vs inline) not defined | Low — can be deferred to implementation. |
| Modal vs inline decision | **Resolved:** modal chosen. |
| Error scenarios (e.g. invalid `expected` range, missing coffee) partially implied in US4 but not explicit | Low — FR2/US4 cover no-coffee; edge cases can be handled in implementation. |
| `TasteDescriptorMap` vs inline mapping — structure not specified | Low — FR5 says "mapping configurable"; implementation can choose. |

## Quality Gates

- **Production safety**: No mocks/placeholders in PRD; FR5 allows "configurable" mapping — implementation must use real copy.
- **File verification**: `PerfectBrew/FeedbackScreen.swift`, `PerfectBrew/Services/LocalizationManager.swift` exist; `PerfectBrew/Views/Taste/` and new views are to be created.
- **Dependencies**: `FeedbackData`, `ActualTasteProfile`, `expectedProfile` (coffee), `LocalizationManager` — all existing.
- **Recipe/audio**: No changes; gates satisfied.

## PerfectBrew Consistency

- SwiftUI + MVVM: New view(s) are View layer; no new ViewModel required unless we extract taste state.
- `FeedbackSection`, `.orange` accent, 8pt grid, `.localized` — called out in PRD and UX checklist.
- Navigation: `NavigationStack` already used; modal would use `.sheet` or overlay — consistent.

---

# Executable Implementation Plan (Phased Checklist)

**Wait for user "approved" before proceeding.**

### Phase 1: Gradient bar + custom scrubber + pill above ✅

- [x] **Task 1**: Add `PerfectBrew/Views/Taste/ExertionStyleTasteView.swift`. Implement full-width `LinearGradient` bar (low→high), `GeometryReader` for layout, and a draggable `Circle` scrubber with `DragGesture`; bind scrubber position to `@Binding var value: Double` (0–1).
- [x] **Task 2**: Add pill (`Capsule`) **above** the bar, horizontally centered on scrubber x; derive pill text (Below/Within/Above expected or Low/Medium/High) and color from `value` and optional `expected` range; use existing `expectedLow`/`expectedHigh` logic.
- [x] **Task 3**: Replace `TasteDimensionSlider` usage in `FeedbackScreen` Taste Profile with `ExertionStyleTasteView` for sweetness, bitterness, acidity; pass `expected` from `expectedProfile` (sweetness, acidity; bitterness 0.5 when coffee selected). Ensure `FeedbackData` 0–1 unchanged; verify submit → Recommendations still works.

### Phase 2: Expected range overlay + descriptor map ✅

- [x] **Task 1**: Implement "expected range" overlay: when `expected != nil`, draw a segment on the gradient bar (from `expectedLow` to `expectedHigh`) with a **hatched** pattern (custom `Shape`/`Path` with diagonal strokes); add "Expected for this coffee" label below the segment.
- [x] **Task 2**: Add `TasteDescriptorMap` (or shared config): map `(value, expected?)` → `(descriptor: String, explanation: String)`. Integrate into `ExertionStyleTasteView`; use localized keys. Start with minimal bands (e.g. below / within / above, or low / medium / high).
- [x] **Task 3**: Add big numeric display (e.g. 0–1 as 1–10 or %) plus descriptor and explanation `Text` views in `ExertionStyleTasteView`; update them when `value` changes. Add `LocalizationManager` keys for new copy (EN + ES).

### Phase 3: Clear / How-to / Save / Dismiss + accessibility ✅

- [x] **Task 1**: Add "Clear Entry" and "How to Self-Assess >" actions. Clear resets all taste dimensions to 0.5; How-to opens `TasteSelfAssessmentGuideView` sheet. Localize both strings.
- [x] **Task 2**: Add **modal** flow: `ExertionStyleTasteModal` — floating card on blurred background; primary "Save" button (orange, subtitle) and secondary "Dismiss" button. Persist taste data on Save and dismiss; Dismiss closes without saving. FeedbackScreen presents modal via "Rate taste" button; Taste Profile section replaced with modal entry.
- [x] **Task 3**: Add `accessibilityAdjustableAction` (increment/decrement, step 1/9) for `ExertionStyleTasteView`; `accessibilityLabel`/`accessibilityHint` for Clear, How-to, Save, Dismiss; 44pt min touch targets for bar overlay and modal buttons.
