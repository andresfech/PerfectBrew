# PRD: Full Recipe Profile Migration

## 🎯 Goal
Eliminate the "30% Baseline" scores by updating **all** remaining recipes with `ExtractionCharacteristics`. This ensures the recommendation engine provides precise, physics-based scores for every recipe in the library.

## 🧩 Strategy: The "Brew Mechanics" Audit
We will categorize each recipe based on its physical brewing actions, not just its title.

### 1. Agitation Audit
- **High**: Stirring, turbulence-inducing pours (e.g., center pours), vacuum cycling.
- **Medium**: Standard circular pours, spin.
- **Low**: Gentle pours, minimal interference, center pour (slow).

### 2. Thermal Audit
- **High**: Boiling water, pre-heating, plastic/glass (low heat loss).
- **Medium**: 90-94°C, standard ceramic.
- **Low**: <90°C, intentional cooling (e.g., Tetsu 4:6 dark roast var).

### 3. Profile Audit (Clarity vs Body)
- **High Clarity (0.7-1.0)**: Fast drawdown, no fines migration, paper filters.
- **Balanced (0.4-0.6)**: Standard V60, Chemex.
- **High Body (0.0-0.3)**: Metal filters, immersion (French Press), slow flow.

## 🛠 Implementation Plan

### Phase 1: V60 Recipes (The Largest Batch)
**Objective**: Differentiate the many V60 styles.
- [ ] **Task 1.1**: Update "Small Batch" series (10g/12g recipes).
  - *Note*: Small doses usually require High Thermal (less mass) and careful Agitation.
- [ ] **Task 1.2**: Update "Champion" recipes (George Stanica, etc.).
- [ ] **Task 1.3**: Update Standard/Legacy V60 recipes.

### Phase 2: AeroPress Recipes
**Objective**: Map the spectrum from "Short Steep" to "Long Steep".
- [ ] **Task 2.1**: Update remaining "World Champion" recipes.
  - *Logic*: Inverted usually = Higher Body. Standard = Higher Clarity.
- [ ] **Task 2.2**: Update "Small Dose Variations" (10g-14g).

### Phase 3: French Press & Chemex
**Objective**: Define the extremes (Immersion vs Thick Filter).
- [ ] **Task 3.1**: Update all French Press recipes (likely High Body, Low Clarity, High Agitation tolerance).
- [ ] **Task 3.2**: Update Chemex recipes (High Clarity due to paper, Medium Agitation).

### Phase 4: Migration & Validation
**Objective**: Sync to Cloud and Test.
- [ ] **Task 4.1**: Run `migrate_recipes_to_supabase.py` to push all updates.
- [ ] **Task 4.2**: Verify no recipes return the default 30% score for a standard coffee profile.

## 📊 Success Metrics
- **Zero 30% Scores**: When a standard coffee is selected, no recipe shows the generic "General recommendation" score (unless it's truly a neutral 30% match by physics, which is rare).
- **Nuance Visibility**: Users can see different scores between "V60 Standard" and "V60 4:6" for the same bean.

