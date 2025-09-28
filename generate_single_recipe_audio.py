#!/usr/bin/env python3
"""
Single Recipe Audio Generator for PerfectBrew
Generates audio for one specific recipe with organized folder structure
"""

import json
import os
import re
from typing import Dict, List, Any
from chatterbox.tts import ChatterboxTTS

class SingleRecipeAudioGenerator:
    def __init__(self):
        self.tts = ChatterboxTTS.from_pretrained(device="cpu")
        print("TTS model loaded successfully!")
    
    def _convert_title_to_folder_name(self, title: str) -> str:
        """Convert recipe title to a valid folder name."""
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
            return title.split(' - ')[0].replace(' ', '_')
    
    def _generate_audio_file(self, audio_script: str, output_path: str) -> bool:
        """Generate audio file from script."""
        try:
            print(f"    Generating audio: {os.path.basename(output_path)}")
            audio_data = self.tts.generate(audio_script)
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with open(output_path, 'wb') as f:
                f.write(audio_data)
            print(f"    ✅ Generated: {os.path.basename(output_path)} ({len(audio_data)} bytes)")
            return True
        except Exception as e:
            print(f"    ❌ Error: {e}")
            return False
    
    def generate_recipe_audio(self, recipe_file: str, base_dir: str) -> None:
        """Generate audio for a single recipe."""
        print(f"🎵 Loading recipe: {recipe_file}")
        
        with open(recipe_file, 'r') as f:
            recipe = json.load(f)
        
        # Handle array format
        if isinstance(recipe, list):
            recipe = recipe[0]
        
        title = recipe.get('title', 'Unknown Recipe')
        brewing_method = recipe.get('brewing_method', 'Unknown')
        
        print(f"📝 Recipe: {title}")
        print(f"☕ Method: {brewing_method}")
        
        # Create organized path: Method/Category/RecipeName/
        category = self._get_recipe_category(title)
        recipe_folder = self._convert_title_to_folder_name(title)
        
        output_dir = os.path.join(base_dir, brewing_method, category, recipe_folder)
        print(f"📁 Output directory: {output_dir}")
        
        # Generate brewing step audio
        if 'brewing_steps' in recipe:
            brewing_steps = recipe['brewing_steps']
            print(f"🎬 Generating {len(brewing_steps)} brewing step audios...")
            
            for i, step in enumerate(brewing_steps, 1):
                audio_script = step.get('audio_script')
                if not audio_script:
                    print(f"    ⚠️  Skipping step {i}: no audio_script")
                    continue
                
                # Use the unique audio_file_name from the recipe
                audio_file_name = step.get('audio_file_name', f"step_{i:02d}.mp3")
                output_path = os.path.join(output_dir, audio_file_name)
                
                print(f"    Step {i}: {audio_script[:50]}...")
                self._generate_audio_file(audio_script, output_path)
        
        print(f"🎉 Audio generation complete for: {title}")

def main():
    generator = SingleRecipeAudioGenerator()
    
    # Generate audio for 2021 Tuomas Merikanto recipe
    recipe_file = "PerfectBrew/Resources/Recipes/AeroPress/World_Champions/2021_Tuomas_Merikanto_Finland/AeroPress_2021_Tuomas_Merikanto_single_serve.json"
    generator.generate_recipe_audio(recipe_file, "PerfectBrew/Resources/Audio")

if __name__ == "__main__":
    main()

