# AEC-13: Full Spanish Localization

## Relevant Files
- `PerfectBrew/Models/Recipe.swift` – BrewingStep, WhatToExpect structs
- `PerfectBrew/Services/AudioService.swift` – Audio playback service
- `PerfectBrew/Services/LocalizationManager.swift` – UI string translations
- `PerfectBrew/Resources/Recipes/` – 38 recipe JSON files
- `universal_audio_generator.py` – TTS audio generation script

## Tasks

### Phase 1: Model Updates
- [x] 1.1 Update `BrewingStep` struct with Spanish fields (`instructionEs`, `audioScriptEs`, `audioFileNameEs`)
- [x] 1.2 Update `WhatToExpect` struct with Spanish fields (`descriptionEs`, `audioScriptEs`, `audioFileNameEs`)
- [x] 1.3 Add `preparationStepsEs` to Recipe and computed `localizedX` properties

### Phase 2: Service Updates
- [x] 2.1 Update `AudioService.swift` for language-aware audio selection
- [x] 2.2 Update UI components to use localized properties

### Phase 3: Translation Database
- [x] 3.1 Create `recipes_es.json` translation master file (structure only)
- [x] 3.2 Create `migrate_spanish_translations.py` script
- [x] 3.3 Translate ALL 38 recipes (automated - needs manual refinement for quality)

### Phase 4: Spanish Audio Generation
- [x] 4.1 Update `universal_audio_generator.py` with `--language` flag
- [ ] 4.2 Test Chatterbox TTS with Spanish text (requires local TTS setup)
- [ ] 4.3 Batch generate Spanish audio files (requires local TTS setup)

### Phase 5: UI String Audit
- [x] 5.1 Add missing Spanish strings to `LocalizationManager`
- [ ] 5.2 Full flow test in Spanish

## ⚠️ AI Instructions
1. Execute ONE task at a time
2. Mark `[x]` when complete
3. Wait for user "yes" before continuing
4. Fallback to English if Spanish not available

