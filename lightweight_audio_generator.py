#!/usr/bin/env python3
"""
Lightweight Audio Generator - Uses pyttsx3 (much less memory)
"""

import json
import os
import re
import pyttsx3
from typing import Dict, List, Any

class LightweightAudioGenerator:
    def __init__(self):
        print("Loading lightweight TTS engine...")
        try:
            self.engine = pyttsx3.init()
            # Configure voice settings
            voices = self.engine.getProperty('voices')
            if voices:
                self.engine.setProperty('voice', voices[0].id)  # Use first available voice
            self.engine.setProperty('rate', 150)  # Speed of speech
            self.engine.setProperty('volume', 0.9)  # Volume level
            print("✅ Lightweight TTS engine loaded successfully!")
        except Exception as e:
            print(f"❌ Error loading TTS engine: {e}")
            exit(1)
    
    def _convert_title_to_folder_name(self, title: str) -> str:
        folder_name = re.sub(r'[^\w\s-]', '', title)
        folder_name = re.sub(r'[-\s]+', '_', folder_name)
        return folder_name.strip('_')
    
    def _get_recipe_category(self, title: str) -> str:
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
        """Generate audio file using lightweight TTS."""
        try:
            print(f"    🎵 Generating: {os.path.basename(output_path)}")
            print(f"    📝 Script: {audio_script[:50]}...")
            
            # Save audio to file
            self.engine.save_to_file(audio_script, output_path)
            self.engine.runAndWait()
            
            # Check if file was created and has content
            if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
                file_size = os.path.getsize(output_path)
                print(f"    ✅ Generated: {os.path.basename(output_path)} ({file_size} bytes)")
                return True
            else:
                print(f"    ❌ Failed: {os.path.basename(output_path)} is empty or missing")
                return False
                
        except Exception as e:
            print(f"    ❌ Error: {e}")
            return False
    
    def generate_recipe_audio(self, recipe_file: str, base_dir: str) -> None:
        """Generate audio for a single recipe."""
        print(f"🎵 Loading recipe: {recipe_file}")
        
        with open(recipe_file, 'r') as f:
            recipe = json.load(f)
        
        if isinstance(recipe, list):
            recipe = recipe[0]
        
        title = recipe.get('title', 'Unknown Recipe')
        brewing_method = recipe.get('brewing_method', 'Unknown')
        
        print(f"📝 Recipe: {title}")
        print(f"☕ Method: {brewing_method}")
        
        # Create organized path
        category = self._get_recipe_category(title)
        recipe_folder = self._convert_title_to_folder_name(title)
        output_dir = os.path.join(base_dir, brewing_method, category, recipe_folder)
        print(f"📁 Output directory: {output_dir}")
        
        # Generate brewing step audio
        if 'brewing_steps' in recipe:
            brewing_steps = recipe['brewing_steps']
            print(f"🎬 Generating {len(brewing_steps)} brewing step audios...")
            
            success_count = 0
            for i, step in enumerate(brewing_steps, 1):
                audio_script = step.get('audio_script')
                if not audio_script:
                    print(f"    ⚠️  Skipping step {i}: no audio_script")
                    continue
                
                audio_file_name = step.get('audio_file_name', f"step_{i:02d}.mp3")
                output_path = os.path.join(output_dir, audio_file_name)
                
                if self._generate_audio_file(audio_script, output_path):
                    success_count += 1
                
                print(f"    Progress: {i}/{len(brewing_steps)} steps")
        
        print(f"🎉 Audio generation complete! {success_count} files generated.")

def main():
    generator = LightweightAudioGenerator()
    recipe_file = "PerfectBrew/Resources/Recipes/AeroPress/World_Champions/2021_Tuomas_Merikanto_Finland/AeroPress_2021_Tuomas_Merikanto_single_serve.json"
    generator.generate_recipe_audio(recipe_file, "PerfectBrew/Resources/Audio")

if __name__ == "__main__":
    main()

