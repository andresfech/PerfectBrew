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
        Validate and rewrite audio text to fit within step duration.
        
        Args:
            text: Original text to validate
            max_duration_seconds: Maximum duration allowed for this step
            step_name: Name of the step for logging
            
        Returns:
            Validated (possibly rewritten) text
        """
        # Estimate audio duration: ~4.5 characters per second for narrated speech
        # This accounts for natural pauses and pronunciation clarity
        max_chars = int(max_duration_seconds * 4.5)
        
        if len(text) <= max_chars:
            return text
            
        # Text is too long, need to rewrite intelligently
        print(f"    ⚠️  {step_name}: Text too long ({len(text)} chars > {max_chars} chars for {max_duration_seconds}s)")
        
        # Rewrite the text to be more concise while preserving key information
        rewritten_text = self._rewrite_audio_script(text, max_chars, max_duration_seconds)
        
        print(f"    ✏️  {step_name}: Rewritten to {len(rewritten_text)} chars")
        return rewritten_text
    
    def _rewrite_audio_script(self, original_text: str, max_chars: int, max_duration: int) -> str:
        """
        Intelligently rewrite audio script to fit duration while preserving key information.
        
        Args:
            original_text: Original audio script
            max_chars: Maximum characters allowed
            max_duration: Maximum duration in seconds
            
        Returns:
            Rewritten concise audio script
        """
        # Key brewing terms and their concise alternatives
        replacements = {
            "milliliters": "mL",
            "milliliter": "mL", 
            "grams": "g",
            "gram": "g",
            "degrees Celsius": "°C",
            "degrees": "°C",
            "temperature": "temp",
            "approximately": "about",
            "carefully": "",
            "gently": "",
            "slowly": "",
            "make sure to": "",
            "you want to": "",
            "you should": "",
            "it's important to": "",
            "this will help": "this helps",
            "in order to": "to",
            "at this point": "now",
            "continue to": "",
            "go ahead and": "",
            "Let's start with": "Start",
            "Now for the": "",
            "Time for the": "",
            "Perfect! Now": "Now",
            "Excellent! Now": "Now",
            "This time": "Now",
            "You should see": "Watch for",
            "coffee bed": "bed",
            "coffee grounds": "grounds",
            "Pour water": "Pour",
            "the center of the": "center",
            "small circles": "circles",
            "gentle swirl": "swirl",
            "controlled": "",
            "steady": "",
            "evenly": "",
        }
        
        # Apply replacements
        rewritten = original_text
        for long_form, short_form in replacements.items():
            rewritten = rewritten.replace(long_form, short_form)
        
        # Remove extra spaces and clean up
        rewritten = " ".join(rewritten.split())
        
        # If still too long, extract key action words
        if len(rewritten) > max_chars:
            # Extract the most important brewing actions
            key_phrases = []
            
            # Look for key brewing actions
            if "pour" in rewritten.lower():
                if "40" in rewritten and "ml" in rewritten.lower():
                    key_phrases.append("Pour 40mL for bloom")
                elif "256" in rewritten and "ml" in rewritten.lower():
                    key_phrases.append("Pour to 256mL total")
                elif "center" in rewritten.lower():
                    key_phrases.append("Pour in center")
                else:
                    key_phrases.append("Pour water")
                    
            if "swirl" in rewritten.lower():
                key_phrases.append("Swirl dripper")
                
            if "bloom" in rewritten.lower():
                key_phrases.append("Bloom phase")
                
            if "wait" in rewritten.lower() or "let" in rewritten.lower():
                key_phrases.append("Wait")
                
            if "grind" in rewritten.lower():
                key_phrases.append("Grind coffee")
                
            if "heat" in rewritten.lower() and "water" in rewritten.lower():
                key_phrases.append("Heat water")
                
            # Create concise script from key phrases
            if key_phrases:
                rewritten = ". ".join(key_phrases) + "."
            else:
                # Fallback: take first part of rewritten text
                words = rewritten.split()
                rewritten = ""
                for word in words:
                    if len(rewritten + word + " ") <= max_chars - 1:
                        rewritten += word + " "
                    else:
                        break
                rewritten = rewritten.strip() + "."
        
        return rewritten.strip()
    
    def _create_narration_style(self, text: str, is_detailed_script: bool = False) -> str:
        """
        Transform text into professional coffee brewing narration.
        Uses warm, engaging tone of an expert barista guide.
        
        Args:
            text: Text to enhance
            is_detailed_script: True if text is already a detailed audioScript
        """
        if is_detailed_script:
            # For detailed audioScript, enhance with professional narration
            enhanced_text = text
            
            # Enhance measurements and technical terms for richer narration
            enhanced_text = re.sub(r'\b(\d+)\s*mL\b', r'\1 milliliters', enhanced_text)
            enhanced_text = re.sub(r'\b(\d+)\s*g\b', r'\1 grams', enhanced_text)
            enhanced_text = re.sub(r'\b(\d+)\s*°C\b', r'\1 degrees Celsius', enhanced_text)
            enhanced_text = re.sub(r'\bV60\b', 'V-sixty dripper', enhanced_text)
            
            # Add engaging language for better listening experience
            enhanced_text = re.sub(r'\bWatch\b', 'Notice how', enhanced_text)
            enhanced_text = re.sub(r'\bNow we\'ll\b', 'Now we will', enhanced_text)
            
            # Add strategic pauses and emphasis
            enhanced_text = re.sub(r'\.([A-Z])', r'. \1', enhanced_text)  # Pause before new sentences
            enhanced_text = re.sub(r'([.!?])\s+([A-Z])', r'\1. \2', enhanced_text)  # Ensure pauses
            
            return enhanced_text
        else:
            # For basic instructions, apply full enhancement
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
    
    def _generate_audio_file(self, text: str, output_path: str, is_detailed_script: bool = False) -> bool:
        """Generate audio file from text using TTS."""
        try:
            # Clean and enhance text
            clean_text = self._clean_text(text)
            enhanced_text = self._create_narration_style(clean_text, is_detailed_script)
            
            print(f"    Generating audio for: {clean_text[:50]}...")
            
            # Set narrator style for TTS (if supported by model)
            if is_detailed_script:
                # Professional barista narrator style - warm, expert, engaging
                narrator_style = "professional_instructor"
            else:
                narrator_style = "friendly_guide"
            
            # Generate audio with enhanced text only (no prompt in audio)
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
                # Use audioScript if available, otherwise fallback to instruction
                audio_text = step.get('audio_script') or step.get('instruction', '')
                is_detailed = bool(step.get('audio_script'))
                
                # Note: audioScript should be pre-sized for step duration in JSON
                
                # Log which text source we're using
                if is_detailed:
                    print(f"    Using detailed audioScript for step {i} ({len(audio_text)} chars)")
                else:
                    print(f"    Using instruction fallback for step {i} ({len(audio_text)} chars)")
                
                # Use original filename from JSON if available, otherwise default naming
                original_filename = step.get('audio_file_name')
                if original_filename and original_filename.endswith('.wav'):
                    filename = original_filename
                else:
                    filename = f"brewing_step_{i:02d}.wav"
                output_path = os.path.join(output_dir, filename)
                if not self._generate_audio_file(audio_text, output_path, is_detailed):
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
