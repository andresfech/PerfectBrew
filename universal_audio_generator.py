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
    
    def _create_narration_style(self, text: str) -> str:
        """
        Transform text into professional audiobook narration style.
        Uses warm, paced tone with strategic pauses.
        """
        # Add professional narration style
        enhanced_text = f"Welcome to PerfectBrew. {text}"
        
        # Add strategic pauses after important sentences
        enhanced_text = re.sub(r'\.([A-Z])', r'. \1', enhanced_text)  # Pause before new sentences
        enhanced_text = re.sub(r'([.!?])\s+([A-Z])', r'\1. \2', enhanced_text)  # Ensure pauses
        
        # Add warmth and engagement
        enhanced_text = enhanced_text.replace("Pour", "Now, let's pour")
        enhanced_text = enhanced_text.replace("Start", "Let's start")
        enhanced_text = enhanced_text.replace("Stop", "Now, let's stop")
        enhanced_text = enhanced_text.replace("Wait", "Let's wait")
        enhanced_text = enhanced_text.replace("Give", "Let's give")
        enhanced_text = enhanced_text.replace("Add", "Let's add")
        enhanced_text = enhanced_text.replace("Heat", "Let's heat")
        enhanced_text = enhanced_text.replace("Grind", "Let's grind")
        enhanced_text = enhanced_text.replace("Place", "Let's place")
        enhanced_text = enhanced_text.replace("Rinse", "Let's rinse")
        
        # Add subtle surprise and engagement
        enhanced_text = enhanced_text.replace("Bloom", "Ah, the bloom")
        enhanced_text = enhanced_text.replace("Swirl", "Gently swirl")
        enhanced_text = enhanced_text.replace("Stir", "Carefully stir")
        enhanced_text = enhanced_text.replace("Final", "And now, the final")
        
        # Add professional closing
        enhanced_text += " Perfect. You've mastered this technique. Enjoy your perfect brew."
        
        return enhanced_text
    
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
    
    def _generate_audio_file(self, text: str, output_path: str) -> bool:
        """Generate audio file from text using TTS."""
        try:
            # Clean and enhance text
            clean_text = self._clean_text(text)
            enhanced_text = self._create_narration_style(clean_text)
            
            print(f"    Generating audio for: {clean_text[:50]}...")
            
            # Generate audio
            wav = self.tts.generate(enhanced_text)
            
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
        Generate audio for a specific recipe using its existing instructions.
        
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
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        success = True
        
        # Generate preparation step audio
        if include_preparation and 'preparation_steps' in recipe:
            preparation_steps = recipe['preparation_steps']
            for i, step in enumerate(preparation_steps, 1):
                filename = f"preparation_step_{i:02d}.wav"
                output_path = os.path.join(output_dir, filename)
                if not self._generate_audio_file(step, output_path):
                    success = False
        
        # Generate brewing step audio
        if include_brewing and 'brewing_steps' in recipe:
            brewing_steps = recipe['brewing_steps']
            for i, step in enumerate(brewing_steps, 1):
                # Use the instruction field from the step
                instruction = step.get('instruction', '')
                filename = f"brewing_step_{i:02d}.wav"
                output_path = os.path.join(output_dir, filename)
                if not self._generate_audio_file(instruction, output_path):
                    success = False
        
        # Generate notes audio
        if include_notes and 'notes' in recipe:
            notes = recipe.get('notes', '')
            if notes:
                filename = "notes.wav"
                output_path = os.path.join(output_dir, filename)
                if not self._generate_audio_file(notes, output_path):
                    success = False
        
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
            
            # Create recipe-specific output directory
            safe_title = re.sub(r'[^\w\s-]', '', title).replace(' ', '_')
            recipe_output_dir = os.path.join(base_output_dir, brewing_method, safe_title)
            
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
