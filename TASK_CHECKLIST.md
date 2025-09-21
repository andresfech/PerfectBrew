# Recipe Audio Narration Enhancement - Task Checklist

## 🎯 Goal
Enhance PerfectBrew recipes with comprehensive audio narration by adding detailed text descriptions for TTS generation while maintaining clean UI with concise step descriptions.

## 📂 Relevant Files
- PerfectBrew/Models/Recipe.swift – BrewingStep struct enhancement
- PerfectBrew/Resources/recipes_aeropress.json – Sample recipe content updates
- universal_audio_generator.py – Chatterbox TTS integration updates

## 📋 Tasks

### Phase 1: Model Enhancement (Low Risk)
- [x] 1.1 Add `audioScript` field to BrewingStep struct
- [x] 1.2 Update CodingKeys enum with `audio_script` mapping
- [x] 1.3 Add backward compatibility in decoder for missing audioScript

### Phase 2: Recipe Content Enhancement (Medium Risk)
- [x] 2.1 Add `audioScript` to James Hoffmann AeroPress recipe
- [x] 2.2 Add `audioScript` to V60 recipe (user priority)
- [x] 2.3 Test JSON loading with new fields and validate backward compatibility

### Phase 3: Audio Generation Integration (Low Risk)
- [x] 3.1 Update `universal_audio_generator.py` to use audioScript field
- [x] 3.2 Generate new audio files for enhanced recipes using Chatterbox
- [x] 3.3 Test audio file integration and playback in iOS app

## ⚠️ AI Instructions
1. **Check Next Task** – Identify current uncompleted `[ ]` sub-task
2. **Execute Single Task** – Complete only current item
3. **Update Progress** – Mark `[x]` and save file
4. **Wait for Approval** – Get user "yes" before continuing
5. **Production Safety** – All code must be production-ready, no placeholders

## 🛡 Safety Checklist
- [ ] Verify file paths exist via codebase_search
- [ ] Use real recipe data only
- [ ] Include proper error handling
- [ ] Maintain audio-step mapping integrity
- [ ] Preserve existing JSON structure
- [ ] Ensure timer accuracy maintained

---
**ALL TASKS COMPLETED** ✅
