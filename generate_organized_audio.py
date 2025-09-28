#!/usr/bin/env python3
"""
Organized Audio Generator for PerfectBrew
Generates audio files with proper folder structure: Method/RecipeName/audio_files
"""

import json
import os
import re
from typing import Dict, List, Any, Optional
from chatterbox.tts import ChatterboxTTS
import torch

class OrganizedAudioGenerator:
    def __init__(self, device: str = "cpu"):
        """Initialize the organized audio generator."""
        self.device = device
        self.tts = None
        self._load_model()
    
    def _load_model(self):
        """Load the TTS model."""
        print("Loading Chatterbox TTS model...")
        self.tts = ChatterboxTTS.from_pretrained(device=self.device)
        print("Model loaded successfully!")
    
    def _convert_title_to_folder_name(self, recipe_title: str) -> str:
        """Convert recipe title to a valid folder name."""
        # Remove special characters and replace spaces with underscores
        folder_name = re.sub(r'[^\w\s-]', '', recipe_title)
        folder_name = re.sub(r'[-\s]+', '_', folder_name)
        return folder_name.strip('_')
    
    def _get_recipe_category(self, recipe_title: str, brewing_method: str) -> str:
        """Determine the recipe category based on title and method."""
        title_lower = recipe_title.lower()
        
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
            return recipe_title.split(' - ')[0].replace(' ', '_')
    
    def _generate_audio_file(self, step: Dict[str, Any], output_path: str) -> bool:
        """Generate audio file for a single step."""
        try:
            audio_script = step.get('audio_script', '')
            if not audio_script:
                return False
            
            # Generate audio using TTS
            audio_data = self.tts.generate(audio_script)
            
            # Save audio file
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with open(output_path, 'wb') as f:
                f.write(audio_data)
            
            print(f"    ✅ Audio file saved: {len(audio_data)} bytes")
            return True
            
        except Exception as e:
            print(f"    ❌ Error generating audio: {e}")
            return False
    
    def generate_recipe_audio(self, recipe: Dict[str, Any], base_output_dir: str) -> bool:
        """Generate audio for a single recipe with organized folder structure."""
        title = recipe.get('title', 'Unknown Recipe')
        brewing_method = recipe.get('brewing_method', 'Unknown')
        
        print(f"\n🎵 Generating audio for: {title}")
        
        # Determine category and create folder structure
        category = self._get_recipe_category(title, brewing_method)
        recipe_folder = self._convert_title_to_folder_name(title)
        
        # Create organized path: Method/Category/RecipeName/
        output_dir = os.path.join(base_output_dir, brewing_method, category, recipe_folder)
        os.makedirs(output_dir, exist_ok=True)
        
        success = True
        
        # Generate brewing step audio
        if 'brewing_steps' in recipe:
            brewing_steps = recipe['brewing_steps']
            for i, step in enumerate(brewing_steps, 1):
                audio_script = step.get('audio_script')
                if not audio_script:
                    print(f"    ⚠️  Skipping brewing step {i}: no audio_script")
                    continue
                
                print(f"    Using audio_script for step {i} ({len(audio_script)} chars)")
                
                # Use the unique audio_file_name from the recipe
                audio_file_name = step.get('audio_file_name', f"step_{i:02d}.mp3")
                output_path = os.path.join(output_dir, audio_file_name)
                
                if not self._generate_audio_file(step, output_path):
                    success = False
        
        if success:
            print(f"🎉 Audio generation complete for: {title}")
        else:
            print(f"⚠️  Audio generation completed with some errors for: {title}")
        
        return success
    
    def generate_all_aeropress_audio(self, base_output_dir: str) -> None:
        """Generate audio for all AeroPress recipes."""
        print("🚀 Organized Audio Generator for PerfectBrew")
        print("=" * 60)
        
        # AeroPress recipes directory
        aeropress_dir = "PerfectBrew/Resources/Recipes/AeroPress"
        
        # Find all JSON files recursively
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
                        self.generate_recipe_audio(recipe, base_output_dir)
                else:
                    self.generate_recipe_audio(recipes, base_output_dir)
                    
            except Exception as e:
                print(f"❌ Error processing {json_file}: {e}")

def main():
    """Main function."""
    generator = OrganizedAudioGenerator()
    generator.generate_all_aeropress_audio("PerfectBrew/Resources/Audio")

if __name__ == "__main__":
    main()

