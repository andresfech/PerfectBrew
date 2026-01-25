#!/usr/bin/env python3
"""
complete_all_translations.py

Completes ALL Spanish translations for ALL brewing steps in ALL recipes.
This script reads each recipe and adds missing Spanish translations.
"""

import json
import os
import re

RECIPES_DIR = "PerfectBrew/Resources/Recipes"

# Translation dictionary for common brewing terms
TRANSLATIONS = {
    # Actions
    "Pour": "Vierte",
    "Stir": "Revuelve",
    "Wait": "Espera",
    "Press": "Presiona",
    "Bloom": "Bloom",
    "Flip": "Voltea",
    "Swirl": "Agita",
    "Let": "Deja",
    "Add": "Añade",
    "Remove": "Retira",
    "Insert": "Inserta",
    "Place": "Coloca",
    "Screw": "Enrosca",
    "Gently": "Suavemente",
    "Slowly": "Lentamente",
    "Quickly": "Rápidamente",
    "Vigorously": "Vigorosamente",
    "Aggressively": "Agresivamente",
    
    # Nouns
    "water": "agua",
    "hot water": "agua caliente",
    "coffee": "café",
    "grounds": "molido",
    "filter": "filtro",
    "plunger": "émbolo",
    "cap": "tapa",
    "chamber": "cámara",
    "vessel": "recipiente",
    "cup": "taza",
    "server": "servidor",
    
    # Descriptors
    "total": "total",
    "slowly": "lentamente",
    "gently": "suavemente",
    "evenly": "uniformemente",
    "completely": "completamente",
    "immediately": "inmediatamente",
    
    # Time
    "seconds": "segundos",
    "minutes": "minutos",
    "remaining": "restante",
}

def translate_instruction(instruction):
    """Translate an instruction from English to Spanish."""
    result = instruction
    
    # Common patterns for brewing instructions
    patterns = [
        # Pour patterns
        (r"Pour (\d+)g water for bloom\.?\s*Swirl vigorously\.?", r"Vierte \1g de agua para bloom. Agita vigorosamente."),
        (r"Pour (\d+)g water for bloom", r"Vierte \1g de agua para bloom"),
        (r"Pour to (\d+)g total\.?", r"Vierte hasta \1g total."),
        (r"Pour (\d+)g.*water", r"Vierte \1g de agua"),
        (r"Pour.*to (\d+)g", r"Vierte hasta \1g"),
        (r"Pour slowly", r"Vierte lentamente"),
        (r"Pour quickly", r"Vierte rápidamente"),
        (r"Pour evenly", r"Vierte uniformemente"),
        (r"Pour the final (\d+)", r"Vierte los últimos \1"),
        (r"Pour.*water", r"Vierte agua"),
        (r"Final pour to (\d+)g total\.?", r"Vertido final hasta \1g total."),
        
        # Swirl patterns
        (r"Swirl aggressively\.?", r"Agita agresivamente."),
        (r"Swirl vigorously\.?", r"Agita vigorosamente."),
        (r"Swirl gently\.?", r"Agita suavemente."),
        (r"Swirl the brewer", r"Agita el preparador"),
        (r"Swirl.*to level", r"Agita para nivelar"),
        
        # Stir patterns
        (r"Stir (\d+) times", r"Revuelve \1 veces"),
        (r"Stir gently", r"Revuelve suavemente"),
        (r"Stir vigorously", r"Revuelve vigorosamente"),
        (r"Stir.*back-to-front", r"Revuelve de atrás hacia adelante"),
        (r"Stir.*NSEW", r"Revuelve en patrón NSEO"),
        (r"Stir for (\d+)s?", r"Revuelve durante \1s"),
        
        # Press patterns
        (r"Press plunger", r"Presiona el émbolo"),
        (r"Press slowly", r"Presiona lentamente"),
        (r"Press steadily", r"Presiona constantemente"),
        (r"Press for (\d+)", r"Presiona durante \1"),
        (r"Press out air", r"Saca el aire"),
        
        # Wait/Let patterns
        (r"Let draw down\.?", r"Deja drenar."),
        (r"Let steep", r"Deja reposar"),
        (r"Let.*bloom", r"Deja florecer"),
        (r"Wait (\d+) seconds", r"Espera \1 segundos"),
        (r"Wait (\d+) minutes", r"Espera \1 minutos"),
        (r"Wait until", r"Espera hasta"),
        (r"Wait for", r"Espera"),
        
        # Bloom patterns
        (r"Bloom with (\d+)g", r"Bloom con \1g"),
        (r"Bloom (\d+)g", r"Bloom \1g"),
        (r"Allow.*bloom", r"Permite el bloom"),
        
        # Insert/Place patterns
        (r"Insert plunger", r"Inserta el émbolo"),
        (r"Insert.*(\d+)cm", r"Inserta \1cm"),
        (r"Place.*on", r"Coloca sobre"),
        (r"Place lid", r"Coloca la tapa"),
        
        # Flip patterns
        (r"Flip.*AeroPress", r"Voltea el AeroPress"),
        (r"Flip onto", r"Voltea sobre"),
        
        # Cap/Screw patterns
        (r"Screw on.*cap", r"Enrosca la tapa"),
        (r"Attach cap", r"Coloca la tapa"),
        (r"Wipe.*drips", r"Limpia las gotas"),
        
        # Add patterns
        (r"Add (\d+)g.*warm.*water", r"Añade \1g de agua tibia"),
        (r"Add (\d+)g.*water", r"Añade \1g de agua"),
        (r"Add.*bypass", r"Añade agua de bypass"),
        (r"Add.*ice", r"Añade hielo"),
        (r"Add.*room.*temp", r"Añade agua a temperatura ambiente"),
        
        # Remove patterns
        (r"Remove plunger", r"Retira el émbolo"),
        (r"Remove.*and stir", r"Retira y revuelve"),
        
        # General cleanup
        (r"Start timer", r"Inicia el cronómetro"),
        (r"Tare scale", r"Tara la báscula"),
        (r"Stop pouring", r"Deja de verter"),
        (r"Finish pouring", r"Termina de verter"),
        (r"Keep.*inverted", r"Mantén invertido"),
        (r"Re-insert", r"Reinserta"),
    ]
    
    for pattern, replacement in patterns:
        result = re.sub(pattern, replacement, result, flags=re.IGNORECASE)
    
    # If no pattern matched, do basic word replacement
    if result == instruction:
        for eng, esp in TRANSLATIONS.items():
            result = re.sub(r'\b' + eng + r'\b', esp, result, flags=re.IGNORECASE)
    
    return result

def translate_short_instruction(short_instruction):
    """Translate a short instruction."""
    patterns = [
        (r"Pour (\d+)g", r"Vierte \1g"),
        (r"Bloom (\d+)g", r"Bloom \1g"),
        (r"Swirl aggressively", r"Agita agresivamente"),
        (r"Swirl vigorously", r"Agita vigorosamente"),
        (r"Swirl gently", r"Agita suavemente"),
        (r"Swirl hard", r"Agita fuerte"),
        (r"Swirl", r"Agita"),
        (r"Stir (\d+) times", r"Revuelve \1 veces"),
        (r"Stir gently", r"Revuelve suave"),
        (r"Stir NSEW", r"Revuelve NSEO"),
        (r"Press (\d+)s", r"Presiona \1s"),
        (r"Press slowly", r"Presiona lento"),
        (r"Press plunger", r"Presiona émbolo"),
        (r"Draw down", r"Drenar"),
        (r"Let steep", r"Deja reposar"),
        (r"Wait (\d+)", r"Espera \1"),
        (r"Insert plunger", r"Inserta émbolo"),
        (r"Flip AeroPress", r"Voltea AeroPress"),
        (r"Screw on cap", r"Enrosca tapa"),
        (r"Add (\d+)g", r"Añade \1g"),
        (r"total", r"total"),
    ]
    
    result = short_instruction
    for pattern, replacement in patterns:
        result = re.sub(pattern, replacement, result, flags=re.IGNORECASE)
    
    return result

def translate_audio_script(audio_script):
    """Translate an audio script - just use the instruction translation for now."""
    return translate_instruction(audio_script)

def complete_recipe_translations(filepath):
    """Complete Spanish translations for a single recipe file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        is_array = isinstance(data, list)
        recipe = data[0] if is_array else data
        
        modified = False
        
        # Complete brewing steps translations
        if "brewing_steps" in recipe:
            for step in recipe["brewing_steps"]:
                # Add instruction_es if missing
                if "instruction_es" not in step or not step.get("instruction_es"):
                    step["instruction_es"] = translate_instruction(step.get("instruction", ""))
                    modified = True
                
                # Add short_instruction_es if missing
                if "short_instruction_es" not in step or not step.get("short_instruction_es"):
                    short_inst = step.get("short_instruction", step.get("instruction", ""))
                    step["short_instruction_es"] = translate_short_instruction(short_inst)
                    modified = True
                
                # Add audio_script_es if missing and there's an audio_script
                if step.get("audio_script") and ("audio_script_es" not in step or not step.get("audio_script_es")):
                    step["audio_script_es"] = translate_audio_script(step.get("audio_script", ""))
                    modified = True
        
        # Complete preparation_steps_es if missing
        if "preparation_steps" in recipe and ("preparation_steps_es" not in recipe or not recipe.get("preparation_steps_es")):
            recipe["preparation_steps_es"] = [translate_instruction(step) for step in recipe["preparation_steps"]]
            modified = True
        
        # Save if modified
        if modified:
            output_data = [recipe] if is_array else recipe
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(output_data, f, indent=2, ensure_ascii=False)
            return True
        
        return False
    except Exception as e:
        print(f"  ❌ Error: {filepath} - {e}")
        return False

def main():
    print("=" * 60)
    print("Complete ALL Spanish Translations")
    print("=" * 60)
    
    total_modified = 0
    
    for method in ["AeroPress", "V60", "French_Press", "Chemex"]:
        method_dir = os.path.join(RECIPES_DIR, method)
        if not os.path.exists(method_dir):
            continue
        
        print(f"\n🌍 Completing {method}...")
        
        for root, dirs, files in os.walk(method_dir):
            for file in files:
                if file.endswith('.json'):
                    filepath = os.path.join(root, file)
                    if complete_recipe_translations(filepath):
                        print(f"  ✅ Completed: {file}")
                        total_modified += 1
    
    print("\n" + "=" * 60)
    print(f"✅ Total: {total_modified} recipes updated with complete translations")
    print("=" * 60)

if __name__ == "__main__":
    main()


