#!/usr/bin/env python3
"""
Premium Audio Script Generator for PerfectBrew
Generates highly specific, detailed, and engaging audio narration for coffee recipes.
Focuses on creating professional-quality audio content with specific timing and technique guidance.
"""

import json
import os
import re
from typing import Dict, List, Any, Tuple
from chatterbox.tts import ChatterboxTTS
import torch

class PremiumAudioScriptGenerator:
    def __init__(self):
        # Force CPU usage to avoid CUDA issues
        self.device = "cpu"
        self.torch_dtype = "float32"
        
        # Initialize TTS model
        print("Loading Chatterbox TTS model...")
        self.tts = ChatterboxTTS.from_pretrained(device=self.device, torch_dtype=self.torch_dtype)
        print("Model loaded successfully!")
        
        # Premium narration templates with specific technique guidance
        self.narration_templates = {
            "preparation": {
                "water_heating": "Let's begin by heating your water to exactly {temperature}°C. This precise temperature is crucial for optimal extraction. While the water heats up, we'll prepare our equipment and set up our workspace.",
                "grinding": "Now, let's grind {coffee_grams} grams of coffee to {grind_size} consistency. The grind size is absolutely critical - it should be {grind_description}. Take your time to get this perfect, as it will determine the entire extraction profile.",
                "filter_setup": "Place your {brewer_type} filter in the brewer and rinse it thoroughly with hot water. This preheats the brewer, removes any paper taste, and ensures consistent temperature throughout the brew. Make sure to discard the rinse water completely.",
                "coffee_bed": "Add your {coffee_grams} grams of ground coffee to the filter. Gently shake the brewer to level the bed, then create a {divot_description} in the center. This divot will help with even water distribution during the bloom phase."
            },
            "brewing": {
                "bloom_start": "It's time to start the bloom phase. Pour {water_amount}mL of water into the center divot, then move in a circular motion to the outside grounds. This initial pour should saturate all the coffee evenly and create a consistent slurry.",
                "bloom_swirl": "Immediately after pouring, give the brewer a gentle swirl to distribute the water evenly. Then, using your stirring device, gently stir through the bed in a zig-zag pattern to break up any dry pockets. This ensures complete saturation and even extraction.",
                "bloom_wait": "Now we wait for the bloom to complete. This {bloom_time}-second period allows the coffee to de-gas, which is essential for fresh coffee. You should see the coffee bed rise and bubble slightly, indicating proper saturation.",
                "main_pour_start": "Time for the main pour. Pour aggressively, full tilt, directly into the middle of the coffee bed. This breaks up any channels and raises the slurry temperature, which is crucial for extraction. The aggressive pour helps ensure even saturation.",
                "main_pour_spiral": "Now swirl out to the edges in a controlled spiral motion. Aim for {target_amount}mL in this stage, reaching {total_amount}mL total. The key is to maintain a steady, controlled pour rate throughout this phase.",
                "pour_pause": "Stop pouring and give the brewer a gentle swirl to flatten the bed. This helps ensure even extraction and prevents channeling. Take a moment to observe the coffee bed - it should be relatively flat and even.",
                "final_pour_start": "Now for the final pour. Begin pouring very gently in the center, maintaining the water level with small circles. This gentle approach prevents over-extraction of the coffee bed and maintains the delicate balance of flavors.",
                "final_pour_continue": "Continue pouring in small circles until you reach {total_water}mL. The water above the coffee may become clear - this is normal and indicates good extraction. Maintain this gentle approach throughout.",
                "final_swirl": "Give one more slight swirl to flatten the bed for even drain down. This final step ensures consistent extraction and a clean finish. The bed should be completely flat now.",
                "drain_wait": "Now let the coffee drain completely. This should take about {drain_time} seconds. The total brew time should be around {total_time} minutes. Take a moment to appreciate the aroma as the coffee finishes extracting."
            },
            "special_techniques": {
                "hoffmann_bloom": "Start your timer now. Pour {water_amount} grams of water, which is exactly {ratio}x your coffee dose. This precise ratio ensures proper saturation without over-wetting. The timing is critical here.",
                "hoffmann_swirl": "Gently swirl the brewer until the coffee slurry is completely even. This even distribution is crucial for consistent extraction throughout the brew. Take your time to get this right.",
                "hoffmann_wait": "Let the coffee bloom until {bloom_end_time}. This extended bloom period allows for proper de-gassing, which is especially important for fresh coffee. Watch for the bed to rise and bubble.",
                "hoffmann_first_pour": "Begin your first main pour. Pour up to {first_pour_amount} grams of water within {pour_time} seconds. This pour keeps the V60 topped up and maintains consistent extraction. The timing is crucial.",
                "hoffmann_second_pour": "Now for the second main pour. Gently pour up to {second_pour_amount} grams of water within {pour_time} seconds. This completes your total water volume. Maintain the gentle approach.",
                "hoffmann_stir": "Stir gently clockwise and then anticlockwise, about {revolutions} revolutions each way. This dislodges any grounds from the sides and ensures all coffee particles are engaged in extraction. Be gentle but thorough.",
                "hoffmann_final_swirl": "Give the brewer a gentle swirl to flatten the coffee bed. A flat bed is preferred for consistent drawdown and even extraction. This final step is crucial for quality.",
                "rao_pour": "Pour {water_amount} grams of water, which is {ratio}x your coffee weight. This higher ratio ensures complete saturation. Stir gently to incorporate all the coffee and create an even slurry.",
                "rao_controlled_pour": "Pour to {target_amount} grams in {pour_time} seconds. Maintain a gentle, controlled pour rate. This consistency is key to the Rao method and ensures even extraction.",
                "rao_swirl": "Give a gentle swirl after each pour. This helps maintain even extraction and prevents channeling. The Rao method relies on minimal agitation for optimal results.",
                "kasuya_ratio": "Pour {water_amount} grams of water, which is {percentage}% of your total water. The 4:6 method focuses on controlling sweetness and acidity through precise pour timing. This is the key to the method.",
                "kasuya_swirl": "After pouring, give a gentle swirl. This method requires minimal agitation to maintain the delicate balance of flavors. The swirl should be very gentle and controlled."
            },
            "timing_guidance": {
                "start_timer": "Start your timer now. We'll be following precise timing for each step. The timing is absolutely critical for this recipe's success.",
                "time_check": "At {time_marker}, you should be {action_description}. This timing is crucial for the recipe's success. Stay focused on the timing.",
                "pace_guidance": "Take your time with this step. Rushing can lead to uneven extraction, while going too slow can cause over-extraction. Find the right pace.",
                "rhythm_guidance": "Find a steady rhythm for your pours. Consistency is more important than speed in coffee brewing. Maintain this rhythm throughout."
            },
            "quality_indicators": {
                "bloom_observation": "Watch the coffee bed during the bloom. You should see it rise and bubble slightly. This indicates fresh coffee and proper saturation. The bed should look even and consistent.",
                "extraction_observation": "Notice how the water flows through the coffee bed. It should be steady and even, not too fast or too slow. This indicates proper grind size and technique.",
                "bed_observation": "The coffee bed should remain relatively flat throughout the brew. This indicates even extraction and good technique. A flat bed is a sign of quality brewing.",
                "aroma_guidance": "Take a moment to appreciate the aroma. You should notice {aroma_notes} as the coffee extracts. The aroma will tell you a lot about the extraction quality."
            }
        }
    
    def enhance_preparation_step(self, step: str, recipe: Dict[str, Any], step_index: int) -> str:
        """Enhance preparation steps with more specific and engaging narration."""
        enhanced = step
        
        # Water heating enhancement
        if "heat water" in step.lower() or "temperature" in step.lower():
            temp = recipe.get("parameters", {}).get("temperature_celsius", 95)
            enhanced = self.narration_templates["preparation"]["water_heating"].format(
                temperature=temp
            )
        
        # Grinding enhancement
        elif "grind" in step.lower():
            coffee_grams = recipe.get("parameters", {}).get("coffee_grams", 20)
            grind_size = recipe.get("parameters", {}).get("grind_size", "medium-fine")
            grind_description = self._get_grind_description(grind_size)
            enhanced = self.narration_templates["preparation"]["grinding"].format(
                coffee_grams=coffee_grams,
                grind_size=grind_size,
                grind_description=grind_description
            )
        
        # Filter setup enhancement
        elif "filter" in step.lower() or "rinse" in step.lower():
            brewer_type = self._get_brewer_type(recipe)
            enhanced = self.narration_templates["preparation"]["filter_setup"].format(
                brewer_type=brewer_type
            )
        
        # Coffee bed setup enhancement
        elif "coffee" in step.lower() and ("add" in step.lower() or "place" in step.lower()):
            coffee_grams = recipe.get("parameters", {}).get("coffee_grams", 20)
            divot_description = "small well" if coffee_grams <= 30 else "deep divot"
            enhanced = self.narration_templates["preparation"]["coffee_bed"].format(
                coffee_grams=coffee_grams,
                divot_description=divot_description
            )
        
        return enhanced
    
    def enhance_brewing_step(self, step: Dict[str, Any], recipe: Dict[str, Any], step_index: int) -> str:
        """Enhance brewing steps with more specific and engaging narration."""
        instruction = step.get("instruction", "")
        time_seconds = step.get("time_seconds", 0)
        recipe_params = recipe.get("parameters", {})
        
        # Determine step type and enhance accordingly
        if "bloom" in instruction.lower():
            return self._enhance_bloom_step(instruction, recipe_params, time_seconds)
        elif "pour" in instruction.lower():
            return self._enhance_pour_step(instruction, recipe_params, time_seconds, step_index)
        elif "swirl" in instruction.lower():
            return self._enhance_swirl_step(instruction, recipe_params, time_seconds)
        elif "stir" in instruction.lower():
            return self._enhance_stir_step(instruction, recipe_params, time_seconds)
        elif "drain" in instruction.lower() or "wait" in instruction.lower():
            return self._enhance_drain_step(instruction, recipe_params, time_seconds)
        else:
            return self._enhance_generic_step(instruction, recipe_params, time_seconds)
    
    def _enhance_bloom_step(self, instruction: str, params: Dict[str, Any], time_seconds: int) -> str:
        """Enhance bloom step with specific guidance."""
        water_amount = params.get("bloom_water_grams", 50)
        bloom_time = params.get("bloom_time_seconds", 45)
        coffee_grams = params.get("coffee_grams", 20)
        
        if "start timer" in instruction.lower():
            ratio = water_amount / coffee_grams
            return f"Start your timer now. Pour {water_amount} grams of water, which is exactly {ratio:.1f}x your coffee dose. This precise ratio ensures proper saturation without over-wetting. The timing is critical here."
        elif "swirl" in instruction.lower():
            return f"Immediately after pouring, give the brewer a gentle swirl to distribute the water evenly. Then, using your stirring device, gently stir through the bed in a zig-zag pattern to break up any dry pockets. This ensures complete saturation and even extraction."
        else:
            return f"Let the coffee bloom for {bloom_time} seconds. This period allows the coffee to de-gas, which is essential for fresh coffee. You should see the coffee bed rise and bubble slightly, indicating proper saturation."
    
    def _enhance_pour_step(self, instruction: str, params: Dict[str, Any], time_seconds: int, step_index: int) -> str:
        """Enhance pour step with specific guidance."""
        total_water = params.get("water_grams", 300)
        coffee_grams = params.get("coffee_grams", 20)
        
        if "main pour" in instruction.lower() or "aggressively" in instruction.lower():
            return f"Time for the main pour. Pour aggressively, full tilt, directly into the middle of the coffee bed. This breaks up any channels and raises the slurry temperature, which is crucial for extraction. Now swirl out to the edges in a controlled spiral motion."
        elif "final pour" in instruction.lower() or "gently" in instruction.lower():
            return f"Now for the final pour. Begin pouring very gently in the center, maintaining the water level with small circles. Continue pouring in small circles until you reach {total_water}mL. The water above the coffee may become clear - this is normal and indicates good extraction."
        else:
            return f"Pour {instruction.split('Pour')[1].split('water')[0].strip()} water. Maintain a steady, controlled pour rate. This consistency is key to achieving the desired extraction profile."
    
    def _enhance_swirl_step(self, instruction: str, params: Dict[str, Any], time_seconds: int) -> str:
        """Enhance swirl step with specific guidance."""
        if "gentle swirl" in instruction.lower():
            return "Give the brewer a gentle swirl to flatten the bed. This helps ensure even extraction and prevents channeling. Take a moment to observe the coffee bed - it should be relatively flat and even."
        elif "final swirl" in instruction.lower():
            return "Give one more slight swirl to flatten the bed for even drain down. This final step ensures consistent extraction and a clean finish. The bed should be completely flat now."
        else:
            return "Give the brewer a gentle swirl. This helps maintain even extraction and prevents channeling. The swirl should be controlled and gentle."
    
    def _enhance_stir_step(self, instruction: str, params: Dict[str, Any], time_seconds: int) -> str:
        """Enhance stir step with specific guidance."""
        if "clockwise" in instruction.lower() and "anticlockwise" in instruction.lower():
            return "Stir gently clockwise and then anticlockwise, about 1 to 1.5 revolutions each way. This dislodges any grounds from the sides and ensures all coffee particles are engaged in extraction. Be gentle but thorough."
        else:
            return "Stir gently through the coffee bed. This helps break up any dry pockets and ensures complete saturation of all the coffee grounds. Take your time with this step."
    
    def _enhance_drain_step(self, instruction: str, params: Dict[str, Any], time_seconds: int) -> str:
        """Enhance drain step with specific guidance."""
        total_time = params.get("total_brew_time_seconds", 300) / 60
        return f"Now let the coffee drain completely. This should take about {time_seconds} seconds. The total brew time should be around {total_time:.1f} minutes. Take a moment to appreciate the aroma as the coffee finishes extracting."
    
    def _enhance_generic_step(self, instruction: str, params: Dict[str, Any], time_seconds: int) -> str:
        """Enhance generic steps with general guidance."""
        return f"{instruction} Take your time with this step to ensure proper execution. The details matter in coffee brewing."
    
    def _get_grind_description(self, grind_size: str) -> str:
        """Get a descriptive explanation of grind size."""
        grind_descriptions = {
            "fine": "very fine, like table salt",
            "medium-fine": "medium-fine, like sand",
            "medium": "medium, like coarse sand",
            "medium-coarse": "medium-coarse, like sea salt",
            "coarse": "coarse, like kosher salt"
        }
        return grind_descriptions.get(grind_size.lower(), "medium-fine consistency")
    
    def _get_brewer_type(self, recipe: Dict[str, Any]) -> str:
        """Get the brewer type from recipe."""
        title = recipe.get("title", "").lower()
        if "v60" in title:
            return "V60"
        elif "aeropress" in title:
            return "AeroPress"
        elif "french press" in title:
            return "French Press"
        else:
            return "brewer"
    
    def generate_premium_audio(self, recipe: Dict[str, Any], output_dir: str) -> None:
        """Generate premium audio for a single recipe."""
        recipe_title = recipe.get("title", "Unknown Recipe")
        print(f"\n🎵 Generating premium audio for: {recipe_title}")
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
        # Generate preparation step audio
        preparation_steps = recipe.get("preparation_steps", [])
        for i, step in enumerate(preparation_steps, 1):
            enhanced_step = self.enhance_preparation_step(step, recipe, i)
            filename = f"preparation_step_{i:02d}.wav"
            self._generate_audio_file(enhanced_step, os.path.join(output_dir, filename))
            print(f"  ✅ Generated: {filename}")
        
        # Generate brewing step audio
        brewing_steps = recipe.get("brewing_steps", [])
        for i, step in enumerate(brewing_steps, 1):
            enhanced_step = self.enhance_brewing_step(step, recipe, i)
            filename = f"brewing_step_{i:02d}.wav"
            self._generate_audio_file(enhanced_step, os.path.join(output_dir, filename))
            print(f"  ✅ Generated: {filename}")
        
        # Generate notes audio
        notes = recipe.get("notes", "")
        if notes:
            enhanced_notes = f"Here are some important notes for this recipe: {notes}. Remember, coffee brewing is both an art and a science. Take your time, be patient, and enjoy the process. The quality of your brew depends on attention to detail."
            filename = "notes.wav"
            self._generate_audio_file(enhanced_notes, os.path.join(output_dir, filename))
            print(f"  ✅ Generated: {filename}")
        
        print(f"🎉 Premium audio generation complete for {recipe_title}!")
    
    def _generate_audio_file(self, text: str, output_path: str) -> None:
        """Generate audio file from text using TTS."""
        try:
            # Clean and prepare text
            text = self._clean_text(text)
            
            # Generate audio
            wav = self.tts.generate(text)
            
            # Save audio file
            import soundfile as sf
            sf.write(output_path, wav, 22050)
            
        except Exception as e:
            print(f"  ❌ Error generating audio: {e}")
    
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
    """Main function to generate premium audio for recipes."""
    print("🚀 Premium Audio Script Generator for PerfectBrew")
    print("=" * 60)
    
    # Initialize generator
    generator = PremiumAudioScriptGenerator()
    
    # Load recipes
    with open("PerfectBrew/Resources/recipes_v60.json", "r") as f:
        recipes = json.load(f)
    
    # Generate audio for each recipe
    for recipe in recipes:
        recipe_title = recipe.get("title", "Unknown Recipe")
        folder_name = recipe_title.replace(" ", "_").replace("-", "_").replace("'", "")
        
        output_dir = f"PerfectBrew/Resources/Audio/V60/{folder_name}_Premium"
        
        try:
            generator.generate_premium_audio(recipe, output_dir)
        except Exception as e:
            print(f"❌ Error processing {recipe_title}: {e}")
            continue
    
    print("\n🎉 Premium audio generation complete for all V60 recipes!")
    print("📁 Audio files saved in: PerfectBrew/Resources/Audio/V60/")

if __name__ == "__main__":
    main()
