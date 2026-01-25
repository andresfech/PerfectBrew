#!/usr/bin/env python3
"""
Batch Spanish Audio Generator for PerfectBrew
Generates Spanish audio for all recipes using audio_script_es fields.
"""

import json
import os
import sys
import glob
from pathlib import Path

# Check if we can import the generator
try:
    from universal_audio_generator import UniversalAudioGenerator
except ImportError:
    print("❌ Cannot import UniversalAudioGenerator. Make sure universal_audio_generator.py is in the same directory.")
    sys.exit(1)

# Configuration
BASE_DIR = Path(__file__).parent
RECIPES_DIR = BASE_DIR / "PerfectBrew" / "Resources" / "Recipes"
AUDIO_DIR = BASE_DIR / "PerfectBrew" / "Resources" / "Audio"

# Mapping of brewing methods to their folder names
METHOD_FOLDERS = {
    "AeroPress": "AeroPress",
    "V60": "V60",
    "French Press": "French_Press",
    "FrenchPress": "French_Press",
    "Chemex": "Chemex"
}

def find_all_recipe_files():
    """Find all recipe JSON files."""
    recipe_files = []
    for method_folder in ["AeroPress", "V60", "French_Press", "Chemex"]:
        folder_path = RECIPES_DIR / method_folder
        if folder_path.exists():
            for json_file in folder_path.rglob("*.json"):
                # Skip grinder files
                if "grinder" in json_file.name.lower():
                    continue
                recipe_files.append(json_file)
    return recipe_files

def get_audio_output_dir(recipe_file: Path, recipe_data: dict) -> Path:
    """Determine the output directory for audio files."""
    # Get brewing method from recipe
    brewing_method = recipe_data.get("brewing_method", "Unknown")
    method_folder = METHOD_FOLDERS.get(brewing_method, brewing_method.replace(" ", "_"))
    
    # Get recipe folder name from the parent directory
    recipe_folder = recipe_file.parent.name
    
    # Construct output path
    output_dir = AUDIO_DIR / method_folder / recipe_folder
    return output_dir

def process_recipe(recipe_file: Path, generator: UniversalAudioGenerator, dry_run: bool = False) -> bool:
    """Process a single recipe file and generate Spanish audio."""
    print(f"\n{'=' * 60}")
    print(f"📄 Processing: {recipe_file.relative_to(BASE_DIR)}")
    
    # Load recipe
    try:
        with open(recipe_file, 'r', encoding='utf-8') as f:
            recipe_data = json.load(f)
    except Exception as e:
        print(f"❌ Error loading recipe: {e}")
        return False
    
    # Handle array vs single recipe
    if isinstance(recipe_data, list):
        recipes = recipe_data
    else:
        recipes = [recipe_data]
    
    for recipe in recipes:
        title = recipe.get("title", "Unknown")
        
        # Check if recipe has Spanish audio scripts
        has_spanish_audio = False
        
        # Check brewing steps
        for step in recipe.get("brewing_steps", []):
            if step.get("audio_script_es"):
                has_spanish_audio = True
                break
        
        # Check what_to_expect
        what_to_expect = recipe.get("what_to_expect", {})
        if isinstance(what_to_expect, dict) and what_to_expect.get("audio_script_es"):
            has_spanish_audio = True
        
        if not has_spanish_audio:
            print(f"⚠️  Skipping '{title}': No Spanish audio scripts found")
            continue
        
        # Determine output directory
        output_dir = get_audio_output_dir(recipe_file, recipe)
        
        print(f"🎵 Recipe: {title}")
        print(f"📂 Output: {output_dir.relative_to(BASE_DIR)}")
        
        # Count scripts to generate
        step_count = sum(1 for s in recipe.get("brewing_steps", []) if s.get("audio_script_es"))
        notes_count = 1 if (isinstance(what_to_expect, dict) and what_to_expect.get("audio_script_es")) else 0
        print(f"📊 Files to generate: {step_count} steps + {notes_count} notes = {step_count + notes_count} total")
        
        if dry_run:
            print("🔍 DRY RUN - Skipping actual generation")
            continue
        
        # Create output directory
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate audio
        try:
            success = generator.generate_recipe_audio(
                recipe=recipe,
                output_dir=str(output_dir),
                include_preparation=False,  # Preparation steps don't have audio
                include_brewing=True,
                include_notes=True
            )
            
            if success:
                print(f"✅ Audio generation complete for: {title}")
            else:
                print(f"⚠️  Audio generation completed with errors for: {title}")
                return False
                
        except Exception as e:
            print(f"❌ Error generating audio: {e}")
            return False
    
    return True

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Batch Spanish Audio Generator for PerfectBrew')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be generated without actually generating')
    parser.add_argument('--method', choices=['AeroPress', 'V60', 'FrenchPress', 'All'], default='All',
                        help='Filter by brewing method')
    parser.add_argument('--recipe', help='Filter by specific recipe name (partial match)')
    parser.add_argument('--device', default='cpu', choices=['cpu', 'cuda'], help='Device for TTS')
    
    args = parser.parse_args()
    
    print("🇪🇸 Spanish Audio Generator for PerfectBrew")
    print("=" * 60)
    
    # Find all recipe files
    recipe_files = find_all_recipe_files()
    print(f"📚 Found {len(recipe_files)} recipe files")
    
    # Filter by method if specified
    if args.method != 'All':
        method_filter = args.method.replace("FrenchPress", "French_Press")
        recipe_files = [f for f in recipe_files if method_filter in str(f)]
        print(f"🔍 Filtered to {len(recipe_files)} {args.method} recipes")
    
    # Filter by recipe name if specified
    if args.recipe:
        recipe_files = [f for f in recipe_files if args.recipe.lower() in f.name.lower()]
        print(f"🔍 Filtered to {len(recipe_files)} recipes matching '{args.recipe}'")
    
    if not recipe_files:
        print("❌ No recipe files found matching criteria")
        return
    
    # Initialize generator (only if not dry run)
    generator = None
    if not args.dry_run:
        print("\n🔧 Initializing Chatterbox TTS (Spanish mode)...")
        try:
            generator = UniversalAudioGenerator(device=args.device, language='es')
        except Exception as e:
            print(f"❌ Failed to initialize TTS: {e}")
            print("💡 Make sure Chatterbox TTS is installed: pip install chatterbox-tts")
            return
    
    # Process each recipe
    success_count = 0
    fail_count = 0
    
    for recipe_file in recipe_files:
        try:
            if process_recipe(recipe_file, generator, args.dry_run):
                success_count += 1
            else:
                fail_count += 1
        except KeyboardInterrupt:
            print("\n\n⚠️  Interrupted by user")
            break
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            fail_count += 1
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 SUMMARY")
    print("=" * 60)
    print(f"✅ Successful: {success_count}")
    print(f"❌ Failed: {fail_count}")
    print(f"📁 Total processed: {success_count + fail_count}")
    
    if args.dry_run:
        print("\n💡 This was a DRY RUN. Run without --dry-run to generate audio files.")

if __name__ == "__main__":
    main()


