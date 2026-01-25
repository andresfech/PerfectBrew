# PRD: Taste Feedback — 1–5 Scale, Acidity / Sweetness / Body Only

## Summary

Unify taste feedback on a **1–5 scale** and align dimensions with the Expected Profile: **Acidity, Sweetness, Body** only. Remove **Bitterness** from user input. **Body** becomes a 1–5 slider (like Expected Profile), not a light/medium/full picker. Expected Profile already uses a 5-dot scale; the exertion-style taste modal will use the same 1–5 scale.

**UX / “too much info”:** We are **reducing** cognitive load:
- **Before:** 4 inputs (sweetness, bitterness, acidity sliders 0–1 → displayed 1–10 + body picker). Two scales (1–10 vs 5-dot).
- **After:** 3 inputs (acidity, sweetness, body sliders, all 1–5). One scale, matches Expected Profile. Fewer dimensions (no bitterness), same three as “According to this coffee, you should taste…”.

---

## Gherkin User Stories

**US1 – Unified 1–5 scale**
- **Given** the user is on the Feedback Taste Profile modal  
- **When** they rate a dimension (acidity, sweetness, or body)  
- **Then** they use a 1–5 scale consistent with the Expected Profile 5-dot display  

**US2 – Dimensions match Expected Profile**
- **Given** Expected Profile shows Acidity, Sweetness, Body (5-dot each)  
- **When** the user opens the Taste Profile modal  
- **Then** they rate only **Acidity**, **Sweetness**, and **Body** (no Bitterness)  

**US3 – Body as 1–5 slider**
- **Given** the user is rating taste  
- **When** they rate body  
- **Then** they use a 1–5 slider (not light/medium/full)  

**US4 – Clear resets to middle**
- **Given** the user has set any taste dimensions  
- **When** they tap “Clear Entry”  
- **Then** acidity, sweetness, and body reset to 3 (middle of 1–5)  

**US5 – Legacy brews still display**
- **Given** a stored brew has old FeedbackData (bitterness, body string)  
- **When** viewing brew history or recommendations  
- **Then** we derive 1–5 / display safely without crashing  

---

## Functional Requirements

| ID | Requirement |
|----|-------------|
| FR1 | Taste input uses **1–5** only (display and stored value). |
| FR2 | Dimensions: **Acidity**, **Sweetness**, **Body**. No Bitterness in UI or new stored feedback. |
| FR3 | Body: 1–5 slider. Remove light/medium/full picker from taste modal. |
| FR4 | Expected band (hatched): convert `ExtractionCharacteristics` 0–1 → 1–5 when rendering. |
| FR5 | Clear Entry resets all three dimensions to 3. |
| FR6 | `ActualTasteProfile` / diagnostics continue to use 0–1 internally; map 1–5 → 0–1 on ingestion. |
| FR7 | Backward compatibility: decode old `FeedbackData` (bitterness, body string); encode new (bodyLevel 1–5, no bitterness). |

---

## Non-Goals

- Changing `ExtractionCharacteristics` or recipe JSON (still 0–1).
- Removing bitterness from `ActualTasteProfile` or `SmartDiagnosticService` internals (we can set it to 0.5 when not collected; phase-out later if desired).
- Changing Expected Profile **card** layout (keep 5-dot display).

---

## Affected Files

| File | Changes |
|------|---------|
| `PerfectBrew/FeedbackScreen.swift` | `canSubmit` (acidity/sweetness/body 1–5, no bitterness/body string); Brew init (`strengthRating`/`acidityRating` from new model). |
| `PerfectBrew/Models/BrewRecommendation.swift` | `ActualTasteProfile.from`: 1–5 → 0–1, body from `bodyLevel`; `bodyToDouble` for legacy `body` string. |
| `PerfectBrew/Views/Taste/ExertionStyleTasteView.swift` | Value 1–5 (not 0–1); display 1–5; expected 1–5; `TasteDescriptorMap` thresholds 1–5; `accessibilityAdjustableAction` step 1. |
| `PerfectBrew/Views/Taste/ExertionStyleTasteModal.swift` | Drop Bitterness; Body as slider (draftBody 1–5); Clear resets to 3; remove body picker. |
| `PerfectBrew/BrewHistoryScreen.swift` | `comparativeLabel` 1–5; show Acidity, Sweetness, Body only; remove Bitterness; body from `bodyLevel` or legacy. |
| `PerfectBrew/Services/LocalizationManager.swift` | `taste_self_assess_guide` (acidity, sweetness, body); any new keys. |
| `PerfectBrew/Models/FeedbackData` (in `FeedbackScreen.swift`) | Add `bodyLevel: Double` (1–5); retain `body: String?` for legacy decode; deprecate `bitternessLevel` (keep for decode, never set in new UI). |
| `PerfectBrew/Services/SmartDiagnosticService.swift` | `ActualTasteProfile.from` already maps; set `bitterness` = 0.5 when not collected. No other change required for this PRD. |

---

## Data Model

**FeedbackData (new shape):**
- `acidityLevel: Double` — 1–5 (was 0–1).
- `sweetnessLevel: Double` — 1–5 (was 0–1).
- `bodyLevel: Double` — 1–5 (new; replaces body for new input).
- `body: String?` — **retain for legacy decode only**. When we have `bodyLevel`, we can derive `body` for backward compat if needed.
- `bitternessLevel: Double` — **deprecated**. Keep for decode of old data; never set by new UI.

**Conversions:**
- **1–5 → 0–1:** `(x - 1) / 4`
- **0–1 → 1–5:** `x * 4 + 1`
- **Legacy body string → bodyLevel:** light → 1.5, medium → 3, full → 4.5 (or similar).
- **Brew `strengthRating`:** historically from bitterness. Use `bodyLevel` → 0–4, e.g. `Int(round((bodyLevel - 1)))`, or leave 0.
- **Brew `acidityRating`:** `Int(round(acidityLevel - 1))` → 0–4.

---

## Git Strategy

- Branch: `feature/taste-1-5-acidity-sweetness-body`
- Commits: (1) Data model + `ActualTasteProfile`; (2) ExertionStyleTasteView 1–5 + modal; (3) BrewHistory, canSubmit, Brew init, compat.

---

## QA Strategy

- **LLM:** Lint; build; grep for `bitternessLevel` / `body` assignation; verify 1–5 in modal, expected band, clear.
- **Manual:** Feedback flow → Taste modal → rate 1–5, clear, save; brew history shows acidity/sweetness/body only; existing brews still open.

---

## PRD Review / Executable Implementation Plan

### Phase 1: Data model + ActualTasteProfile / FeedbackData ✅

- [x] **Task 1:** Add `bodyLevel: Double` (1–5) to `FeedbackData`. Retain `body: String?` for decode. Keep `bitternessLevel` for decode only; do not set in new UI. Defaults: `acidityLevel`/`sweetnessLevel`/`bodyLevel` = 3. Implement `Codable` so we can decode legacy (`bitternessLevel`, `body`) and encode new (`bodyLevel`).
- [ ] **Task 2:** Update `ActualTasteProfile.from(feedback:)`: map 1–5 → 0–1 for acidity, sweetness, body; use `bodyLevel` when present, else `bodyToDouble(body)`. Set `bitterness` = 0.5 when not from feedback (or from legacy `bitternessLevel` if present).
- [ ] **Task 3:** Update `FeedbackScreen` `canSubmit` to use `acidityLevel`/`sweetnessLevel`/`bodyLevel` (1–5) and drop `bitternessLevel`/`body` from “has taste” check. Update Brew init: `acidityRating` from `acidityLevel` 1–5 → 0–4; `strengthRating` from `bodyLevel` 1–5 → 0–4 (or 0 if no body).

### Phase 2: ExertionStyleTasteView 1–5 + modal Acidity/Sweetness/Body

- [x] **Task 1:** Change `ExertionStyleTasteView` to **1–5** value range: `@Binding var value: Double` (1…5), `expected: Double?` (1…5). Display big number 1–5. Gradient/scrubber/hatched band use 1–5. Update `TasteDescriptorMap` thresholds for 1–5 (e.g. expected ±0.5; low &lt;2, high &gt;4).
- [x] **Task 2:** Update `ExertionStyleTasteModal`: three sliders only — **Acidity**, **Sweetness**, **Body**. Remove Bitterness and body picker. Draft state `draftAcidity`, `draftSweetness`, `draftBody` (1–5). Clear resets all to 3. Pass `expectedProfile` 0–1 → 1–5 when providing `expected` to each slider.
- [x] **Task 3:** `accessibilityAdjustableAction` increment/decrement by 1 (clamped 1–5). Localization: `taste_self_assess_guide` mentions acidity, sweetness, body only. Ensure “Expected for this coffee” and pill copy still make sense for 1–5.

### Phase 3: BrewHistory, canSubmit, Brew init, diagnostics compat ✅

- [x] **Task 1:** Update `BrewHistoryScreen`: `comparativeLabel(for:)` works on 1–5 (e.g. 1–2 → “not enough”, 3 → “perfect”, 4–5 → “too much”). Display only Acidity, Sweetness, Body; remove Bitterness. Use `bodyLevel` when present, else legacy `body` string.
- [x] **Task 2:** Confirm `canSubmit` and Brew init use new model (Phase 1). Ensure `SmartDiagnosticService` receives `ActualTasteProfile` with `bitterness` = 0.5 when not collected; no behavioral change required for diagnostics beyond that.
- [x] **Task 3:** Run full feedback flow (with and without coffee), save, view history. Verify VoiceOver, 44pt targets, and UX checklist. Fix any regressions.

---

## Success Metrics

- Taste modal and Expected Profile use the same **1–5** scale.
- Users rate only **Acidity**, **Sweetness**, **Body** (no Bitterness).
- Body is a **1–5** slider.
- Legacy brews still decode and display correctly.
