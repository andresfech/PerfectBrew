#!/usr/bin/env python3
"""
Simple Audio Structure Organizer for PerfectBrew
Creates clean folder structure: Method/RecipeName/audio_files
"""

import json
import os
import re
from typing import Dict, List, Any
from chatterbox.tts import ChatterboxTTS

class AudioOrganizer:
    def __init__(self):
        self.tts = ChatterboxTTS.from_pretrained(device="cpu")
        print("TTS model loaded successfully!")
    
    def _convert_title_to_folder_name(self, title: str) -> str:
        """Convert recipe title to a valid folder name."""
        # Remove special characters and replace spaces with underscores
        folder_name = re.sub(r'[^\w\s-]', '', title)
        folder_name = re.sub(r'[-\s]+', '_', folder_name)
        return folder_name.strip('_')
    
    def _get_recipe_category(self, title: str) -> str:
        """Determine the recipe category based on title."""
        title_lower = title.lower()
        
        if "world" in title_lower and "champion" in title_lower:
            return "World_Champions"
        elif "james" in title_lower and "hoffmann" in title_lower:
            return "James_Hoffmann"
        elif "tim" in title_lower and "wendelboe" in title_lower:
            return "Tim_Wendelboe"
        elif "championship" in title_lower:
            return "Championship_Concentrate"
        else:
            # Use the first part of the title as category
            return title.split(' - ')[0].replace(' ', '_')
    
    def _generate_audio_file(self, audio_script: str, output_path: str) -> bool:
        """Generate audio file from script."""
        try:
            audio_data = self.tts.generate(audio_script)
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with open(output_path, 'wb') as f:
                f.write(audio_data)
            print(f"    ✅ Generated: {os.path.basename(output_path)}")
            return True
        except Exception as e:
            print(f"    ❌ Error: {e}")
            return False
    
    def process_recipe(self, recipe: Dict[str, Any], base_dir: str) -> None:
        """Process a single recipe and generate organized audio files."""
        title = recipe.get('title', 'Unknown')
        brewing_method = recipe.get('brewing_method', 'Unknown')
        
        print(f"\n🎵 Processing: {title}")
        
        # Create organized path: Method/Category/RecipeName/
        category = self._get_recipe_category(title)
        recipe_folder = self._convert_title_to_folder_name(title)
        
        output_dir = os.path.join(base_dir, brewing_method, category, recipe_folder)
        
        # Generate brewing step audio
        if 'brewing_steps' in recipe:
            for i, step in enumerate(recipe['brewing_steps'], 1):
                audio_script = step.get('audio_script')
                if not audio_script:
                    print(f"    ⚠️  Skipping step {i}: no audio_script")
                    continue
                
                # Use the unique audio_file_name from the recipe
                audio_file_name = step.get('audio_file_name', f"step_{i:02d}.mp3")
                output_path = os.path.join(output_dir, audio_file_name)
                
                self._generate_audio_file(audio_script, output_path)
    
    def organize_all_aeropress(self, base_dir: str) -> None:
        """Organize all AeroPress recipes."""
        print("🚀 Organizing AeroPress Audio Structure")
        print("=" * 50)
        
        # Find all AeroPress JSON files
        aeropress_dir = "PerfectBrew/Resources/Recipes/AeroPress"
        json_files = []
        
        for root, dirs, files in os.walk(aeropress_dir):
            for file in files:
                if file.endswith('.json'):
                    json_files.append(os.path.join(root, file))
        
        print(f"Found {len(json_files)} AeroPress recipe files")
        
        for json_file in json_files:
            try:
                with open(json_file, 'r') as f:
                    recipes = json.load(f)
                
                # Handle both single recipe and array of recipes
                if isinstance(recipes, list):
                    for recipe in recipes:
                        self.process_recipe(recipe, base_dir)
                else:
                    self.process_recipe(recipes, base_dir)
                    
            except Exception as e:
                print(f"❌ Error processing {json_file}: {e}")

def main():
    organizer = AudioOrganizer()
    organizer.organize_all_aeropress("PerfectBrew/Resources/Audio")

if __name__ == "__main__":
    main()

