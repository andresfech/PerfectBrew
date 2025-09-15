#!/usr/bin/env python3
"""
Test script for Universal Audio Generator
Tests with Kaldi's Coffee - Single Serve recipe
"""

import json
import os
from universal_audio_generator import UniversalAudioGenerator

def main():
    """Test the universal audio generator with Kaldi's Coffee recipe."""
    print("🧪 Testing Universal Audio Generator")
    print("=" * 50)
    
    # Initialize generator
    generator = UniversalAudioGenerator(device="cpu")
    
    # Load recipes and find Kaldi's Coffee
    with open("PerfectBrew/Resources/recipes_v60.json", "r") as f:
        recipes = json.load(f)
    
    # Find Kaldi's Coffee - Single Serve
    kaldi_recipe = None
    for recipe in recipes:
        if "Kaldi's Coffee - Single Serve" in recipe.get("title", ""):
            kaldi_recipe = recipe
            break
    
    if not kaldi_recipe:
        print("❌ Kaldi's Coffee - Single Serve recipe not found!")
        return
    
    # Generate audio for this specific recipe
    output_dir = "PerfectBrew/Resources/Audio/V60/Kaldi_Coffee_Single_Serve_Universal"
    success = generator.generate_recipe_audio(kaldi_recipe, output_dir)
    
    if success:
        print("\n🎉 Test completed successfully!")
        print(f"📁 Audio files saved in: {output_dir}")
    else:
        print("\n⚠️  Test completed with some errors")

if __name__ == "__main__":
    main()
