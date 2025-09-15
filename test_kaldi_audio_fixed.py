#!/usr/bin/env python3
"""
Test Audio Script Generator for Kaldi's Coffee - Single Serve (Fixed)
Generates enhanced audio narration specifically for this recipe.
"""

import json
import os
import re
import numpy as np
from typing import Dict, List, Any
from chatterbox.tts import ChatterboxTTS
import torch

class KaldiAudioGeneratorFixed:
    def __init__(self):
        # Force CPU usage to avoid CUDA issues
        self.device = "cpu"
        
        # Initialize TTS model
        print("Loading Chatterbox TTS model...")
        self.tts = ChatterboxTTS.from_pretrained(device=self.device)
        print("Model loaded successfully!")
    
    def enhance_kaldi_preparation_steps(self, recipe: Dict[str, Any]) -> List[str]:
        """Generate enhanced preparation steps for Kaldi's Coffee - Single Serve."""
        params = recipe.get("parameters", {})
        coffee_grams = params.get("coffee_grams", 16)
        temperature = params.get("temperature_celsius", 96)
        grind_size = params.get("grind_size", "Medium-fine")
        
        enhanced_steps = [
            f"Let's begin by heating your water to exactly {temperature}°C. This precise temperature is crucial for optimal extraction. While the water heats up, we'll prepare our equipment and set up our workspace.",
            f"Now, let's grind {coffee_grams} grams of coffee to medium-fine consistency. The grind size is absolutely critical - it should be like sand, allowing for a long, steady pour with a slight pool of water on top. Take your time to get this perfect, as it will determine the entire extraction profile.",
            "Place your V60 filter in the brewer and rinse it thoroughly with 50 to 100 milliliters of hot water. This preheats the brewer, removes any paper taste, and ensures consistent temperature throughout the brew. Make sure to discard the rinse water completely.",
            f"Add your {coffee_grams} grams of ground coffee to the filter. Gently shake the brewer to level the bed, then create a small well in the center. This divot will help with even water distribution during the bloom phase."
        ]
        
        return enhanced_steps
    
    def enhance_kaldi_brewing_steps(self, recipe: Dict[str, Any]) -> List[str]:
        """Generate enhanced brewing steps for Kaldi's Coffee - Single Serve."""
        params = recipe.get("parameters", {})
        bloom_water = params.get("bloom_water_grams", 40)
        total_water = params.get("water_grams", 256)
        bloom_time = params.get("bloom_time_seconds", 45)
        total_time = params.get("total_brew_time_seconds", 250) / 60
        
        enhanced_steps = [
            f"Start your timer now. It's time to start the bloom phase. Pour {bloom_water} milliliters of water into the center divot, then move in a circular motion to the outside grounds. This initial pour should saturate all the coffee evenly and create a consistent slurry.",
            "Immediately after pouring, give the brewer a gentle swirl to distribute the water evenly. Then, using your stirring device, gently stir through the bed in a zig-zag pattern to break up any dry pockets. This ensures complete saturation and even extraction.",
            f"Now we wait for the bloom to complete. This {bloom_time}-second period allows the coffee to de-gas, which is essential for fresh coffee. You should see the coffee bed rise and bubble slightly, indicating proper saturation.",
            "Time for the main pour. Pour aggressively, full tilt, directly into the middle of the coffee bed. This breaks up any channels and raises the slurry temperature, which is crucial for extraction. Now swirl out to the edges in a controlled spiral motion. Aim for 75 milliliters in this stage, reaching 115 milliliters total.",
            "Stop pouring and give the brewer a gentle swirl to flatten the bed. This helps ensure even extraction and prevents channeling. Take a moment to observe the coffee bed - it should be relatively flat and even.",
            f"Now for the final pour. Begin pouring very gently in the center, maintaining the water level with small circles. Continue pouring in small circles until you reach {total_water} milliliters. The water above the coffee may become clear - this is normal and indicates good extraction.",
            f"Give one more slight swirl to flatten the bed for even drain down. This final step ensures consistent extraction and a clean finish. Now let the coffee drain completely. The total brew time should be around {total_time:.1f} minutes. Take a moment to appreciate the aroma as the coffee finishes extracting."
        ]
        
        return enhanced_steps
    
    def generate_kaldi_audio(self, recipe: Dict[str, Any], output_dir: str) -> None:
        """Generate enhanced audio for Kaldi's Coffee - Single Serve."""
        title = recipe.get('title', 'Kaldi\'s Coffee - Single Serve')
        print(f"\n🎵 Generating enhanced audio for: {title}")
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        # Generate preparation step audio
        preparation_steps = self.enhance_kaldi_preparation_steps(recipe)
        for i, step in enumerate(preparation_steps, 1):
            filename = f"single_serve_preparation_step_{i:02d}.wav"
            self._generate_audio_file(step, os.path.join(output_dir, filename))
            print(f"  ✅ Generated: {filename}")
        
        # Generate brewing step audio
        brewing_steps = self.enhance_kaldi_brewing_steps(recipe)
        for i, step in enumerate(brewing_steps, 1):
            filename = f"single_serve_brewing_step_{i:02d}.wav"
            self._generate_audio_file(step, os.path.join(output_dir, filename))
            print(f"  ✅ Generated: {filename}")
        
        # Generate notes audio
        notes = recipe.get("notes", "")
        if notes:
            enhanced_notes = f"Here are some important notes for this recipe: {notes}. Remember, coffee brewing is both an art and a science. Take your time, be patient, and enjoy the process. The quality of your brew depends on attention to detail."
            filename = "single_serve_notes.wav"
            self._generate_audio_file(enhanced_notes, os.path.join(output_dir, filename))
            print(f"  ✅ Generated: {filename}")
        
        print(f"🎉 Enhanced audio generation complete for Kaldi's Coffee - Single Serve!")
    
    def _generate_audio_file(self, text: str, output_path: str) -> None:
        """Generate audio file from text using TTS."""
        try:
            # Clean and prepare text
            text = self._clean_text(text)
            print(f"    Generating audio for: {text[:50]}...")
            
            # Generate audio
            wav = self.tts.generate(text)
            
            # Convert to numpy array if needed
            if isinstance(wav, torch.Tensor):
                wav = wav.cpu().numpy()
            
            # Ensure it's a 1D array
            if wav.ndim > 1:
                wav = wav.flatten()
            
            # Save audio file using scipy.io.wavfile
            from scipy.io import wavfile
            wavfile.write(output_path, 22050, (wav * 32767).astype(np.int16))
            
            # Verify file was created and has content
            if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
                print(f"    ✅ Audio file saved successfully: {os.path.getsize(output_path)} bytes")
            else:
                print(f"    ❌ Audio file is empty or not created")
            
        except Exception as e:
            print(f"  ❌ Error generating audio: {e}")
            import traceback
            traceback.print_exc()
    
    def _clean_text(self, text: str) -> str:
        """Clean text for better TTS output."""
        # Remove special characters that might cause TTS issues
        text = re.sub(r'[^\w\s.,!?;:\-()]', '', text)
        
        # Normalize spacing
        text = re.sub(r'\s+', ' ', text)
        
        # Add pauses for better speech rhythm
        text = text.replace('.', '. ')
        text = text.replace(',', ', ')
        
        return text.strip()

def main():
    """Main function to generate enhanced audio for Kaldi's Coffee - Single Serve."""
    print("🚀 Enhanced Audio Generator for Kaldi's Coffee - Single Serve (Fixed)")
    print("=" * 80)
    
    # Initialize generator
    generator = KaldiAudioGeneratorFixed()
    
    # Load recipes and find Kaldi's Coffee - Single Serve
    with open("PerfectBrew/Resources/recipes_v60.json", "r") as f:
        recipes = json.load(f)
    
    # Find the specific recipe
    kaldi_recipe = None
    for recipe in recipes:
        if "Kaldi's Coffee - Single Serve" in recipe.get("title", ""):
            kaldi_recipe = recipe
            break
    
    if not kaldi_recipe:
        print("❌ Kaldi's Coffee - Single Serve recipe not found!")
        return
    
    # Generate audio directly in the original folder
    output_dir = "PerfectBrew/Resources/Audio/V60/Kaldi_Coffee_Single_Serve"
    generator.generate_kaldi_audio(kaldi_recipe, output_dir)
    
    print("\n🎉 Enhanced audio generation complete!")
    print("📁 Audio files saved in: PerfectBrew/Resources/Audio/V60/Kaldi_Coffee_Single_Serve/")

if __name__ == "__main__":
    main()
