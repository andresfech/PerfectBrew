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
    
    def _create_guided_mode_audio(self, text: str, step_duration: int, step_name: str) -> str:
        """
        Create Guided Mode audio with action-timed callouts.
        Breaks every step into micro-actions with specific timing cues.
        
        Args:
            text: Original step text
            step_duration: Duration of the step in seconds
            step_name: Name of the step for context
        """
        # Extract key brewing actions from text
        actions = self._extract_brewing_actions(text)
        
        # Create guided mode script with timing cues
        guided_script = []
        
        # Pre-cue (T-10s or T-5s)
        if step_duration >= 10:
            pre_cue_time = 10
        elif step_duration >= 5:
            pre_cue_time = 5
        else:
            pre_cue_time = 2
            
        if pre_cue_time < step_duration:
            guided_script.append(f"In {pre_cue_time} seconds, {actions['action']}.")
        
        # Go cue (T-0)
        guided_script.append(f"{actions['go_cue']}.")
        
        # Pace cues for longer steps
        if step_duration >= 20:
            # Midpoint cue
            midpoint = step_duration // 2
            guided_script.append(f"Halfway through... keep a steady stream.")
        elif step_duration >= 15:
            # 10-second mark cue
            guided_script.append(f"Keep going... steady pace.")
        
        # Wrap cue (T-5s)
        if step_duration >= 8:
            guided_script.append(f"Five seconds remaining...")
        elif step_duration >= 5:
            guided_script.append(f"Almost done...")
        
        # Next cue (end)
        if actions.get('next_action'):
            guided_script.append(f"Stop. Next: {actions['next_action']}. Ready?")
        
        return ". ".join(guided_script) + "."
    
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
        """Extract brewing actions and create appropriate cues."""
        text_lower = text.lower()
        
        # Determine main action
        if "pour" in text_lower:
            # Extract pour amount and duration
            amount_match = re.search(r'(\d+)\s*(g|grams?|ml|milliliters?)', text_lower)
            amount = amount_match.group(1) + " " + amount_match.group(2) if amount_match else "water"
            
            # Extract duration if mentioned
            duration_match = re.search(r'(\d+)\s*seconds?', text_lower)
            duration = duration_match.group(1) + " seconds" if duration_match else ""
            
            action = f"start pouring {amount}"
            go_cue = f"Pour {amount}"
            next_action = "wait for extraction"
            
        elif "swirl" in text_lower:
            action = "swirl the dripper"
            go_cue = "Swirl now"
            next_action = "wait for drawdown"
            
        elif "stir" in text_lower:
            action = "stir the coffee"
            go_cue = "Stir gently"
            next_action = "wait for bloom"
            
        elif "wait" in text_lower or "let" in text_lower:
            action = "wait for the process"
            go_cue = "Wait"
            next_action = "check the bed"
            
        elif "bloom" in text_lower:
            action = "begin the bloom phase"
            go_cue = "Bloom starts now"
            next_action = "watch for expansion"
            
        elif "heat" in text_lower and "water" in text_lower:
            action = "heat the water"
            go_cue = "Heat water"
            next_action = "prepare the coffee"
            
        elif "grind" in text_lower:
            action = "grind the coffee"
            go_cue = "Grind coffee"
            next_action = "prepare the dripper"
            
        else:
            # Default action
            action = "perform this step"
            go_cue = "Begin now"
            next_action = "continue to next step"
        
        return {
            'action': action,
            'go_cue': go_cue,
            'next_action': next_action
        }
    
    def _create_narration_style(self, text: str, is_detailed_script: bool = False, step_duration: int = 0, step_name: str = "") -> str:
        """
        Transform text into professional coffee brewing narration.
        Uses warm, engaging tone of an expert barista guide with Guided Mode.
        
        Args:
            text: Text to enhance
            is_detailed_script: True if text is already a detailed audioScript
            step_duration: Duration of the step in seconds (for Guided Mode)
            step_name: Name of the step for context
        """
        if is_detailed_script and step_duration > 0:
            # Use Guided Mode for detailed scripts with timing
            return self._create_guided_mode_audio(text, step_duration, step_name)
        elif is_detailed_script:
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
                
                # Calculate step duration for validation
                step_duration = 0
                if i == 1:
                    step_duration = step.get('time_seconds', 0)
                elif i <= len(brewing_steps):
                    prev_step_time = brewing_steps[i-2].get('time_seconds', 0)
                    current_step_time = step.get('time_seconds', 0)
                    step_duration = current_step_time - prev_step_time
                
                print(f"    Using audio_script for step {i} ({len(audio_script)} chars, {step_duration}s duration)")
                
                # Use unified naming convention
                filename = f"step_{i:02d}.wav"
                output_path = os.path.join(recipe_output_dir, filename)
                if not self._generate_audio_file(step, output_path):
                    success = False
        
        # Generate notes audio
        if include_notes and 'notes' in recipe:
            notes = recipe.get('notes', '')
            if notes:
                filename = f"{recipe_prefix}notes.wav"
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
