#!/usr/bin/env python3
"""
Update all recipe JSON files to use .m4a extensions instead of .mp3 or .wav.
This ensures consistency across all recipes.
"""

import os
import json
import glob

def update_recipe_file(file_path):
    """Update a single recipe file to use .m4a extensions."""
    try:
        with open(file_path, 'r') as f:
            recipes = json.load(f)
        
        updated = False
        
        # Process each recipe in the file
        for recipe in recipes:
            # Update brewing steps
            if 'brewing_steps' in recipe:
                for step in recipe['brewing_steps']:
                    if 'audio_file_name' in step:
                        old_name = step['audio_file_name']
                        if old_name.endswith('.mp3') or old_name.endswith('.wav'):
                            step['audio_file_name'] = old_name.rsplit('.', 1)[0] + '.m4a'
                            updated = True
                            print(f"  Updated: {old_name} → {step['audio_file_name']}")
            
            # Update preparation steps (if they have audio)
            if 'preparation_steps' in recipe:
                for step in recipe['preparation_steps']:
                    if isinstance(step, dict) and 'audio_file_name' in step:
                        old_name = step['audio_file_name']
                        if old_name.endswith('.mp3') or old_name.endswith('.wav'):
                            step['audio_file_name'] = old_name.rsplit('.', 1)[0] + '.m4a'
                            updated = True
                            print(f"  Updated: {old_name} → {step['audio_file_name']}")
        
        # Save updated file if changes were made
        if updated:
            with open(file_path, 'w') as f:
                json.dump(recipes, f, indent=2)
            print(f"✅ Updated: {file_path}")
            return True
        else:
            print(f"⏭️  No changes needed: {file_path}")
            return False
            
    except Exception as e:
        print(f"❌ Error updating {file_path}: {e}")
        return False

def main():
    """Update all recipe files to use .m4a extensions."""
    print("🔄 UPDATING ALL RECIPES TO USE M4A EXTENSIONS")
    print("=" * 60)
    
    # Find all recipe JSON files
    recipe_patterns = [
        "PerfectBrew/Resources/Recipes/**/*.json",
        "PerfectBrew/Resources/Recipes/*.json"
    ]
    
    all_files = []
    for pattern in recipe_patterns:
        all_files.extend(glob.glob(pattern, recursive=True))
    
    # Filter out non-recipe files (like Lottie animations)
    recipe_files = []
    for file_path in all_files:
        filename = os.path.basename(file_path)
        if not any(skip in filename.lower() for skip in ['lottie', 'animation', 'thermometer', 'water', 'coffee']):
            recipe_files.append(file_path)
    
    print(f"Found {len(recipe_files)} recipe files to check")
    
    updated_count = 0
    
    for file_path in recipe_files:
        print(f"\n📄 Processing: {file_path}")
        if update_recipe_file(file_path):
            updated_count += 1
    
    print(f"\n📊 SUMMARY:")
    print(f"  Total files processed: {len(recipe_files)}")
    print(f"  Files updated: {updated_count}")
    print(f"  Files unchanged: {len(recipe_files) - updated_count}")
    
    if updated_count > 0:
        print(f"\n✅ All recipe files now use .m4a extensions!")
        print(f"🎯 Next time you generate audio, it will automatically create M4A files.")
    else:
        print(f"\n✅ All recipe files already use .m4a extensions!")

if __name__ == "__main__":
    main()
