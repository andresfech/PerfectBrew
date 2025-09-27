#!/usr/bin/env python3
"""
Universal Audio Generator for PerfectBrew
Generates professional audio narration for any recipe using existing instructions.
"""

import json
import os
import re
import argparse
from typing import Dict, List, Any, Optional
from chatterbox.tts import ChatterboxTTS
import torch
import numpy as np

class UniversalAudioGenerator:
    def __init__(self, device: str = "cpu"):
        """Initialize the universal audio generator."""
        self.device = device
        self.tts = None
        self._load_model()
    
    def _load_model(self):
        """Load the TTS model."""
        print("Loading Chatterbox TTS model...")
        self.tts = ChatterboxTTS.from_pretrained(device=self.device)
        print("Model loaded successfully!")
    
    def _validate_audio_duration(self, text: str, max_duration_seconds: int, step_name: str) -> str:
        """
        Simple validation - just return the text as-is.
        No duration validation or text rewriting.
        """
        return text
    
    def _rewrite_audio_script(self, original_text: str, max_chars: int, max_duration: int) -> str:
        """
        Not used - just return original text.
        """
        return original_text
    
    def _create_guided_mode_audio(self, text: str, step_duration: int, step_name: str) -> str:
        """
        Not used - just return original text.
        """
        return text
    
    def _convert_title_to_folder_name(self, recipe_title: str) -> str:
        """
        Convert recipe title to a valid folder name for audio organization.
        
        Args:
            recipe_title: The title of the recipe
            
        Returns:
            A valid folder name string (e.g., "Tetsu_Kasuya_4_6_Method")
        """
        # Remove special characters and replace spaces with underscores
        folder_name = re.sub(r'[^\w\s]', '', recipe_title)
        folder_name = re.sub(r'\s+', '_', folder_name.strip())
        
        # Limit length to avoid filesystem issues
        if len(folder_name) > 50:
            folder_name = folder_name[:50]
        
        return folder_name
    
    def _extract_brewing_actions(self, text: str) -> Dict[str, str]:
        """Not used - return empty dict."""
        return {}
    
    def _create_narration_style(self, text: str, is_detailed_script: bool = False, step_duration: int = 0, step_name: str = "") -> str:
        """
        Not used - just return original text.
        """
        return text
    
    def _clean_text(self, text: str) -> str:
        """Clean text for better TTS output."""
        # Remove special characters that might cause TTS issues
        text = re.sub(r'[^\w\s.,!?;:\-()]', '', text)
        
        # Normalize spacing
        text = re.sub(r'\s+', ' ', text)
        
        # Add natural pauses
        text = text.replace('.', '. ')
        text = text.replace(',', ', ')
        text = text.replace(':', ': ')
        text = text.replace(';', '; ')
        
        return text.strip()
    
    def _generate_audio_file(self, step: Dict[str, Any], output_path: str) -> bool:
        """Generate audio file from step's audio_script using TTS."""
        try:
            # Get audio_script from step
            audio_script = step.get('audio_script', '')
            if not audio_script:
                print(f"    ❌ No audio_script found in step")
                return False
            
            # Clean text for better TTS output
            clean_text = self._clean_text(audio_script)
            
            print(f"    Generating audio for: {clean_text[:50]}...")
            
            # Generate audio directly from audio_script (no enhancement needed)
            wav = self.tts.generate(clean_text)
            
            # Convert to numpy array if needed
            if isinstance(wav, torch.Tensor):
                wav = wav.cpu().numpy()
            
            # Ensure it's a 1D array
            if wav.ndim > 1:
                wav = wav.flatten()
            
            # Save audio file
            from scipy.io import wavfile
            wavfile.write(output_path, 22050, (wav * 32767).astype(np.int16))
            
            # Verify file was created and has content
            if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
                print(f"    ✅ Audio file saved: {os.path.getsize(output_path)} bytes")
                return True
            else:
                print(f"    ❌ Audio file is empty or not created")
                return False
                
        except Exception as e:
            print(f"    ❌ Error generating audio: {e}")
            return False
    
    def generate_recipe_audio(self, recipe: Dict[str, Any], output_dir: str, 
                            include_preparation: bool = True, 
                            include_brewing: bool = True, 
                            include_notes: bool = True) -> bool:
        """
        Generate audio for a specific recipe using ONLY the audio_script field.
        
        Args:
            recipe: Recipe dictionary from JSON
            output_dir: Output directory for audio files
            include_preparation: Whether to generate preparation step audio
            include_brewing: Whether to generate brewing step audio
            include_notes: Whether to generate notes audio
        
        Returns:
            bool: True if successful, False otherwise
        """
        title = recipe.get('title', 'Unknown Recipe')
        print(f"\n🎵 Generating audio for: {title}")
        
        # Create output directory with recipe name
        recipe_folder = self._convert_title_to_folder_name(title)
        recipe_output_dir = os.path.join(output_dir, recipe_folder)
        os.makedirs(recipe_output_dir, exist_ok=True)
        
        success = True
        
        # Generate preparation step audio
        if include_preparation and 'preparation_steps' in recipe:
            preparation_steps = recipe['preparation_steps']
            for i, step in enumerate(preparation_steps, 1):
                # Skip preparation steps - they don't have audio_script
                print(f"    ⚠️  Skipping preparation step {i}: preparation steps don't have audio_script")
        
        # Generate brewing step audio
        if include_brewing and 'brewing_steps' in recipe:
            brewing_steps = recipe['brewing_steps']
            for i, step in enumerate(brewing_steps, 1):
                # ONLY use audio_script - no fallback to instruction
                audio_script = step.get('audio_script')
                if not audio_script:
                    print(f"    ⚠️  Skipping brewing step {i}: no audio_script")
                    continue
                
                print(f"    Using audio_script for step {i} ({len(audio_script)} chars)")
                
                # Use unified naming convention
                filename = f"step_{i:02d}.wav"
                output_path = os.path.join(recipe_output_dir, filename)
                if not self._generate_audio_file(step, output_path):
                    success = False
        
        # Skip notes audio generation
        
        if success:
            print(f"🎉 Audio generation complete for: {title}")
        else:
            print(f"⚠️  Audio generation completed with some errors for: {title}")
        
        return success
    
    def generate_all_recipes_audio(self, recipes_file: str, base_output_dir: str,
                                 brewing_method: Optional[str] = None,
                                 recipe_title: Optional[str] = None) -> None:
        """
        Generate audio for all recipes or specific recipes.
        
        Args:
            recipes_file: Path to recipes JSON file
            base_output_dir: Base directory for output
            brewing_method: Filter by brewing method (optional)
            recipe_title: Filter by specific recipe title (optional)
        """
        print("🚀 Universal Audio Generator for PerfectBrew")
        print("=" * 60)
        
        # Load recipes
        with open(recipes_file, 'r') as f:
            recipes = json.load(f)
        
        # Filter recipes if needed
        if brewing_method:
            recipes = [r for r in recipes if r.get('brewing_method') == brewing_method]
        
        if recipe_title:
            recipes = [r for r in recipes if recipe_title.lower() in r.get('title', '').lower()]
        
        print(f"Found {len(recipes)} recipes to process")
        
        # Process each recipe
        for recipe in recipes:
            title = recipe.get('title', 'Unknown')
            brewing_method = recipe.get('brewing_method', 'Unknown')
            
            # Create recipe-specific output directory (flat structure)
            # base_output_dir is already the correct path (e.g., PerfectBrew/Resources/Audio/V60/Tetsu_Kasuya)
            recipe_output_dir = base_output_dir
            
            # Generate audio
            self.generate_recipe_audio(recipe, recipe_output_dir)

def main():
    """Main function with command line interface."""
    parser = argparse.ArgumentParser(description='Universal Audio Generator for PerfectBrew')
    parser.add_argument('--recipes', required=True, help='Path to recipes JSON file')
    parser.add_argument('--output', required=True, help='Base output directory')
    parser.add_argument('--method', help='Filter by brewing method (AeroPress, V60, FrenchPress)')
    parser.add_argument('--recipe', help='Filter by specific recipe title')
    parser.add_argument('--device', default='cpu', help='Device to use (cpu or cuda)')
    
    args = parser.parse_args()
    
    # Initialize generator
    generator = UniversalAudioGenerator(device=args.device)
    
    # Generate audio
    generator.generate_all_recipes_audio(
        recipes_file=args.recipes,
        base_output_dir=args.output,
        brewing_method=args.method,
        recipe_title=args.recipe
    )

if __name__ == "__main__":
    main()
