## Relevant Files
- supabase_schema.sql - SQL schema definition for Supabase
- PerfectBrew/Services/SupabaseManager.swift - Singleton service for Supabase integration
- PerfectBrew.xcodeproj/project.pbxproj - Xcode project file (for dependency)

## Tasks

### Phase 1: Setup & Schema Definition
- [x] **Task 1**: Create `supabase_schema.sql` defining the `recipes` table with columns: `id` (UUID), `title` (Text), `method` (Text), `version` (Int), and `json_data` (JSONB) to store the full recipe structure.
- [x] **Task 2**: Define the `grinders` table schema in SQL to store grinder settings (e.g., Timemore C2s) separately, linking to recipes via ID or Name.
- [x] **Task 3**: Add the `supabase-swift` package dependency to the Xcode project and create a `SupabaseManager` singleton service to handle initialization.

### Phase 2: Data Migration & Population
- [x] **Task 1**: Create a Python script `migrate_recipes_to_supabase.py` that reads all local JSON recipes from `PerfectBrew/Resources/Recipes/` and formats them for SQL insertion or API upload.
- [x] **Task 2**: Extend the script to validate that all recipes have required fields (`parameters`, `brewingSteps`) before upload to prevent bad data in the cloud.
- [x] **Task 3**: Execute the migration script to populate the Supabase `recipes` table with the current local dataset (including the new V60 and AeroPress recipes).

### Phase 3: iOS Integration (Read-Only)
- [x] **Task 1**: Update `RecipeDatabase.swift` to include a `fetchRemoteRecipes()` function that calls `SupabaseManager` to get new/updated recipes.
- [x] **Task 2**: Implement a "Merge Strategy" in `RecipeDatabase`: Load local Bundle recipes first, then fetch remote recipes and append/overwrite based on ID/Version.
- [x] **Task 3**: Update `AudioService.swift` logic (Verified: Current logic supports Cloud recipes that reference Bundle audio files. Full remote streaming deferred until remote storage is utilized).

### Phase 4: Testing & Reliability
- [x] **Task 1**: Create a unit test to verify that a fetched JSON from Supabase correctly decodes into the `Recipe` struct (especially the `WhatToExpect` and optional fields).
- [ ] **Task 2**: Test "Offline Mode" by running the app with network disabled to ensure local bundle recipes still load and function 100%.
- [ ] **Task 3**: Test "Live Update" by changing a recipe title in Supabase and verifying the app reflects the change after a refresh/restart.

