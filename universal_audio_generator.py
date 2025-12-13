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
    def __init__(self, device: str = "cpu", language: str = "en"):
        """
        Initialize the universal audio generator.
        
        Args:
            device: Device to use (cpu or cuda)
            language: Language for audio generation (en or es)
        """
        self.device = device
        self.language = language
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
            # AEC-13: Get audio_script based on language setting
            if self.language == 'es':
                audio_script = step.get('audio_script_es', '')
                if not audio_script:
                    # Fallback to English if Spanish not available
                    audio_script = step.get('audio_script', '')
                    print(f"    ⚠️  No Spanish audio_script, falling back to English")
            else:
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
            
            # Convert to M4A format for iOS compatibility
            import subprocess
            import tempfile
            
            # Create temporary WAV file
            with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as temp_wav:
                from scipy.io import wavfile
                wavfile.write(temp_wav.name, 22050, (wav * 32767).astype(np.int16))
                
                # Convert WAV to M4A using ffmpeg
                try:
                    cmd = [
                        'ffmpeg',
                        '-i', temp_wav.name,           # Input WAV file
                        '-c:a', 'aac',                 # Audio codec: AAC
                        '-b:a', '128k',                # Audio bitrate: 128kbps
                        '-ar', '44100',                # Sample rate: 44.1kHz
                        '-ac', '2',                    # Stereo
                        '-y',                          # Overwrite output file
                        output_path
                    ]
                    
                    result = subprocess.run(cmd, capture_output=True, text=True)
                    
                    if result.returncode == 0:
                        print(f"    ✅ Audio file saved as M4A: {os.path.getsize(output_path)} bytes")
                        success = True
                    else:
                        print(f"    ❌ FFmpeg conversion failed: {result.stderr}")
                        success = False
                        
                except FileNotFoundError:
                    print(f"    ❌ FFmpeg not found. Please install ffmpeg: brew install ffmpeg")
                    success = False
                finally:
                    # Clean up temporary file
                    try:
                        os.unlink(temp_wav.name)
                    except:
                        pass
            
            # Verify file was created and has content
            if success and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
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
                
                # AEC-13: Use language-specific audio_file_name
                if self.language == 'es':
                    audio_file_name = step.get('audio_file_name_es') or step.get('audio_file_name', f"step_{i:02d}_es.m4a")
                    # Ensure _es suffix if using fallback
                    if not step.get('audio_file_name_es') and '_es' not in audio_file_name:
                        base_name = audio_file_name.rsplit('.', 1)[0] if '.' in audio_file_name else audio_file_name
                        audio_file_name = f"{base_name}_es.m4a"
                else:
                    audio_file_name = step.get('audio_file_name', f"step_{i:02d}.m4a")
                
                # Convert any existing extension to .m4a
                if '.' in audio_file_name:
                    audio_file_name = audio_file_name.rsplit('.', 1)[0] + '.m4a'
                else:
                    audio_file_name = audio_file_name + '.m4a'
                output_path = os.path.join(recipe_output_dir, audio_file_name)
                if not self._generate_audio_file(step, output_path):
                    success = False
        
        # Generate notes/what_to_expect audio
        if include_notes and 'what_to_expect' in recipe:
            what_to_expect = recipe['what_to_expect']
            if isinstance(what_to_expect, dict):
                # AEC-13: Use language-specific audio_script
                if self.language == 'es':
                    audio_script = what_to_expect.get('audio_script_es') or what_to_expect.get('audio_script')
                    if what_to_expect.get('audio_script_es'):
                        print(f"    Using Spanish audio_script for what_to_expect ({len(audio_script)} chars)")
                    else:
                        print(f"    ⚠️  No Spanish audio_script for what_to_expect, using English")
                else:
                    audio_script = what_to_expect.get('audio_script')
                
                if audio_script:
                    print(f"    Using audio_script for what_to_expect ({len(audio_script)} chars)")
                    
                    # AEC-13: Use language-specific audio_file_name
                    if self.language == 'es':
                        audio_file_name = what_to_expect.get('audio_file_name_es') or what_to_expect.get('audio_file_name', "intro_es.m4a")
                        # Ensure _es suffix if using fallback
                        if not what_to_expect.get('audio_file_name_es') and '_es' not in audio_file_name:
                            base_name = audio_file_name.rsplit('.', 1)[0] if '.' in audio_file_name else audio_file_name
                            audio_file_name = f"{base_name}_es.m4a"
                    else:
                        audio_file_name = what_to_expect.get('audio_file_name', "intro.m4a")
                    
                    # Convert any existing extension to .m4a
                    if '.' in audio_file_name:
                        audio_file_name = audio_file_name.rsplit('.', 1)[0] + '.m4a'
                    else:
                        audio_file_name = audio_file_name + '.m4a'
                        
                    output_path = os.path.join(recipe_output_dir, audio_file_name)
                    if not self._generate_audio_file(what_to_expect, output_path):
                        success = False
                else:
                    print(f"    ⚠️  Skipping what_to_expect: no audio_script")
        
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
    parser.add_argument('--language', '-l', default='en', choices=['en', 'es'],
                        help='Language for audio generation (en=English, es=Spanish)')
    
    args = parser.parse_args()
    
    print(f"🌐 Language: {args.language.upper()}")
    
    # Initialize generator with language setting
    generator = UniversalAudioGenerator(device=args.device, language=args.language)
    
    # Generate audio
    generator.generate_all_recipes_audio(
        recipes_file=args.recipes,
        base_output_dir=args.output,
        brewing_method=args.method,
        recipe_title=args.recipe
    )

if __name__ == "__main__":
    main()
