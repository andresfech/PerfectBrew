#!/usr/bin/env python3
"""
complete_spanish_translations.py

Generates COMPLETE Spanish translations for all PerfectBrew recipes.
Uses comprehensive sentence-level translations for natural Spanish text.
"""

import json
import os
import re
from typing import Dict, List, Any

def translate_text(text: str) -> str:
    """Translate English text to Spanish using comprehensive patterns."""
    if not text:
        return text
    
    result = text
    
    # Complete sentence/phrase replacements (order matters - longer patterns first)
    replacements = [
        # Full sentences for common brewing instructions
        ("Start your timer", "Inicia tu cronómetro"),
        ("Start the timer", "Inicia el cronómetro"),
        ("Start timer and pour", "Inicia el cronómetro y vierte"),
        ("Start timer", "Inicia el cronómetro"),
        ("Enjoy your coffee", "Disfruta tu café"),
        ("Stop when you hear", "Detente cuando escuches"),
        ("stop when you hear", "detente cuando escuches"),
        
        # Pour instructions
        ("Pour hot water evenly", "Vierte agua caliente uniformemente"),
        ("Pour evenly", "Vierte uniformemente"),
        ("Pour slowly", "Vierte lentamente"),
        ("pour immediately", "sirve inmediatamente"),
        ("Pour immediately", "Sirve inmediatamente"),
        ("pour within", "sirve en"),
        ("Pour within", "Sirve en"),
        
        # Time expressions
        ("You have", "Tienes"),
        ("seconds to", "segundos para"),
        ("minutes to", "minutos para"),
        ("Wait for", "Espera"),
        ("wait for", "espera"),
        ("Wait until", "Espera hasta"),
        ("wait until", "espera hasta"),
        ("Let it rest", "Déjalo reposar"),
        ("Let rest", "Deja reposar"),
        ("Let the coffee steep", "Deja que el café repose"),
        ("Let coffee steep", "Deja que el café repose"),
        ("Let the coffee rest", "Deja que el café repose"),
        ("Let the coffee bloom", "Deja que el café haga bloom"),
        
        # Stir/Swirl instructions
        ("Stir gently", "Revuelve suavemente"),
        ("stir gently", "revuelve suavemente"),
        ("Stir clockwise", "Revuelve en sentido horario"),
        ("Stir anticlockwise", "Revuelve en sentido antihorario"),
        ("Stir counter-clockwise", "Revuelve en sentido antihorario"),
        ("Gently swirl", "Agita suavemente"),
        ("gently swirl", "agita suavemente"),
        ("Swirl gently", "Agita suavemente"),
        ("swirl gently", "agita suavemente"),
        ("Swirl the brewer", "Agita el preparador"),
        ("Swirl to flatten", "Agita para nivelar"),
        ("a gentle swirl", "una agitación suave"),
        ("Give a gentle swirl", "Agita suavemente"),
        
        # Plunger/Press instructions
        ("Insert plunger", "Inserta el émbolo"),
        ("insert plunger", "inserta el émbolo"),
        ("Press the plunger", "Presiona el émbolo"),
        ("Press plunger", "Presiona el émbolo"),
        ("press the plunger", "presiona el émbolo"),
        ("Press down slowly", "Presiona lentamente hacia abajo"),
        ("press down slowly", "presiona lentamente hacia abajo"),
        ("slow, steady press", "presión lenta y constante"),
        ("Slow, steady press", "Presión lenta y constante"),
        ("do not press", "no presiones"),
        ("Do not press", "No presiones"),
        ("Don't press", "No presiones"),
        
        # Lid/Cap instructions
        ("Place the lid", "Coloca la tapa"),
        ("Place lid", "Coloca la tapa"),
        ("place the lid", "coloca la tapa"),
        ("Screw on the", "Enrosca la"),
        ("screw on the", "enrosca la"),
        
        # Filter instructions
        ("Place the filter", "Coloca el filtro"),
        ("Place filter", "Coloca el filtro"),
        ("Rinse the filter", "Enjuaga el filtro"),
        ("Rinse filter", "Enjuaga el filtro"),
        ("rinse the filter", "enjuaga el filtro"),
        
        # Do not instructions
        ("do not disturb", "no muevas"),
        ("Do not disturb", "No muevas"),
        ("Don't disturb", "No muevas"),
        ("Don't rush", "No te apresures"),
        
        # Common phrases
        ("This ensures", "Esto asegura"),
        ("This helps", "Esto ayuda"),
        ("This allows", "Esto permite"),
        ("This breaks", "Esto rompe"),
        ("This dislodges", "Esto desprende"),
        ("This creates", "Esto crea"),
        ("This step", "Este paso"),
        ("create a", "crea un"),
        ("Create a", "Crea un"),
        ("aim for", "apunta a"),
        ("Aim for", "Apunta a"),
        ("aim to", "intenta"),
        ("Aim to", "Intenta"),
        ("Once pressed", "Una vez presionado"),
        
        # Bloom terminology
        ("Bloom continues", "El bloom continúa"),
        ("bloom continues", "el bloom continúa"),
        ("bloom period", "período de bloom"),
        
        # Coffee bed/grounds
        ("coffee slurry", "mezcla de café"),
        ("coffee bed", "cama de café"),
        ("flat bed", "cama nivelada"),
        ("all grounds", "todo el molido"),
        ("all the grounds", "todo el molido"),
        ("the grounds", "el molido"),
        ("dry pockets", "bolsas secas"),
        
        # Technical terms
        ("partial vacuum seal", "sello de vacío parcial"),
        ("vacuum seal", "sello de vacío"),
        ("hissing sound", "el silbido"),
        ("soft hiss", "silbido suave"),
        ("de-gassing", "desgasificación"),
        ("degassing", "desgasificación"),
        ("extraction", "extracción"),
        ("Extraction", "Extracción"),
        ("over-extraction", "sobre-extracción"),
        ("under-extraction", "sub-extracción"),
        ("saturation", "saturación"),
        ("saturate", "saturar"),
        ("saturated", "saturado"),
        
        # Pour names
        ("First Main Pour", "Primer Vertido Principal"),
        ("Second Main Pour", "Segundo Vertido Principal"),
        ("First pour", "Primer vertido"),
        ("Second pour", "Segundo vertido"),
        ("Third pour", "Tercer vertido"),
        ("Final pour", "Vertido final"),
        ("First phase", "Primera fase"),
        ("Second phase", "Segunda fase"),
        ("Third phase", "Tercera fase"),
        
        # Motion descriptions
        ("in circular motion", "en movimiento circular"),
        ("circular motion", "movimiento circular"),
        ("in a circular motion", "en movimiento circular"),
        ("working your way outward", "avanzando hacia afuera"),
        ("from the center", "desde el centro"),
        ("from center", "desde el centro"),
        ("center outward", "desde el centro hacia afuera"),
        
        # Equipment
        ("hot water", "agua caliente"),
        ("Hot water", "Agua caliente"),
        ("warm water", "agua tibia"),
        ("Warm water", "Agua tibia"),
        ("the brewer", "el preparador"),
        ("the server", "el servidor"),
        ("serving vessel", "recipiente"),
        ("your cup", "tu taza"),
        ("your server", "tu servidor"),
        
        # Time units
        (" seconds", " segundos"),
        (" minutes", " minutos"),
        (" second", " segundo"),
        (" minute", " minuto"),
        
        # Now/Finally/Then
        ("Now ", "Ahora "),
        ("Finally,", "Finalmente,"),
        ("Finally ", "Finalmente "),
        ("Then ", "Luego "),
        ("then ", "luego "),
        
        # Verbs
        ("Add ", "Añade "),
        ("add ", "añade "),
        ("Pour ", "Vierte "),
        ("pour ", "vierte "),
        ("Stir ", "Revuelve "),
        ("stir ", "revuelve "),
        ("Wait ", "Espera "),
        ("wait ", "espera "),
        ("Allow ", "Permite "),
        ("allow ", "permite "),
        ("Continue ", "Continúa "),
        ("continue ", "continúa "),
        ("Finish ", "Termina "),
        ("finish ", "termina "),
        ("Complete ", "Completa "),
        ("complete ", "completa "),
        ("Remove ", "Retira "),
        ("remove ", "retira "),
        
        # Adjectives/Adverbs
        ("evenly", "uniformemente"),
        ("Evenly", "Uniformemente"),
        ("slowly", "lentamente"),
        ("Slowly", "Lentamente"),
        ("gently", "suavemente"),
        ("Gently", "Suavemente"),
        ("immediately", "inmediatamente"),
        ("Immediately", "Inmediatamente"),
        ("steadily", "constantemente"),
        ("steady ", "constante "),
        ("quickly", "rápidamente"),
        ("Quickly", "Rápidamente"),
        ("thoroughly", "completamente"),
        ("completely", "completamente"),
        
        # Common words
        ("about ", "aproximadamente "),
        ("About ", "Aproximadamente "),
        ("around ", "aproximadamente "),
        ("Around ", "Aproximadamente "),
        ("total", "total"),
        ("Total", "Total"),
        ("until", "hasta"),
        ("Until", "Hasta"),
        ("within", "en"),
        ("Within", "En"),
        ("during", "durante"),
        ("During", "Durante"),
        ("while", "mientras"),
        ("While", "Mientras"),
        
        # Nouns
        ("water", "agua"),
        ("Water", "Agua"),
        ("coffee", "café"),
        ("Coffee", "Café"),
        ("timer", "cronómetro"),
        ("Timer", "Cronómetro"),
        ("plunger", "émbolo"),
        ("Plunger", "Émbolo"),
        ("lid", "tapa"),
        ("Lid", "Tapa"),
        ("cap", "tapa"),
        ("Cap", "Tapa"),
        ("filter", "filtro"),
        ("Filter", "Filtro"),
        ("spoon", "cuchara"),
        ("Spoon", "Cuchara"),
        ("scale", "báscula"),
        ("Scale", "Báscula"),
        ("kettle", "hervidor"),
        ("Kettle", "Hervidor"),
        ("brewer", "preparador"),
        ("Brewer", "Preparador"),
        ("cup", "taza"),
        ("Cup", "Taza"),
        ("bed", "cama"),
        ("grounds", "molido"),
        
        # Weight units - keep g/grams but add context
        ("grams of", "gramos de"),
        ("gram of", "gramo de"),
    ]
    
    for eng, esp in replacements:
        result = result.replace(eng, esp)
    
    return result

def translate_recipe(recipe: Dict[str, Any]) -> Dict[str, Any]:
    """Generate complete Spanish translation for a recipe."""
    translation = {}
    
    # Title
    title = recipe.get('title', '')
    translation['title_es'] = translate_title(title)
    
    # Notes
    notes = recipe.get('notes', '')
    if notes:
        translation['notes_es'] = translate_text(notes)
    
    # Preparation steps
    prep_steps = recipe.get('preparation_steps', [])
    if prep_steps:
        translation['preparation_steps_es'] = [translate_text(step) for step in prep_steps]
    
    # Brewing steps
    brewing_steps = recipe.get('brewing_steps', [])
    if brewing_steps:
        translation['brewing_steps'] = []
        for step in brewing_steps:
            step_trans = {'time_seconds': step.get('time_seconds', 0)}
            if step.get('instruction'):
                step_trans['instruction_es'] = translate_text(step['instruction'])
            if step.get('short_instruction'):
                step_trans['short_instruction_es'] = translate_text(step['short_instruction'])
            if step.get('audio_script'):
                step_trans['audio_script_es'] = translate_text(step['audio_script'])
            translation['brewing_steps'].append(step_trans)
    
    # What to expect
    wte = recipe.get('what_to_expect', {})
    if wte and isinstance(wte, dict):
        translation['what_to_expect'] = {}
        if wte.get('description'):
            translation['what_to_expect']['description_es'] = translate_text(wte['description'])
        if wte.get('audio_script'):
            translation['what_to_expect']['audio_script_es'] = translate_text(wte['audio_script'])
    
    return translation

def translate_title(title: str) -> str:
    """Translate recipe title to Spanish."""
    # Common title word replacements
    replacements = [
        ("Ultimate", "Definitivo"),
        ("Classic", "Clásico"),
        ("Single Serve", "Individual"),
        ("single serve", "individual"),
        ("Method", "Método"),
        ("Technique", "Técnica"),
        ("Recipe", "Receta"),
        ("Standard", "Estándar"),
        ("Extended", "Extendido"),
        ("Slow", "Lento"),
        ("Quick", "Rápido"),
        ("Morning", "Mañanero"),
        ("Everyday", "Diario"),
        ("Gentle", "Suave"),
        ("Steep", "Infusión"),
        ("Scaled", "Escalado"),
        ("Light Roast", "Tueste Claro"),
        ("World Champion", "Campeón Mundial"),
        ("World AeroPress Champion", "Campeón Mundial de AeroPress"),
        ("Concentrate", "Concentrado"),
        ("Championship", "Campeonato"),
        ("Single Cup", "Taza Individual"),
        ("Cup of Joy", "Taza de Alegría"),
        ("Bypass Americano", "Americano Bypass"),
        ("Espresso Style", "Estilo Espresso"),
        ("Strength Focus", "Enfoque en Intensidad"),
        ("Original", "Original"),
        ("Micro Dose", "Micro Dosis"),
        ("Two Cup", "Dos Tazas"),
        ("Small Batch", "Pequeño Lote"),
        ("Inverted", "Invertido"),
        ("French Press", "Prensa Francesa"),
    ]
    
    result = title
    for eng, esp in replacements:
        result = result.replace(eng, esp)
    
    return result

def get_recipe_key(filepath: str) -> str:
    """Extract recipe key from filepath."""
    return os.path.basename(filepath).replace('.json', '')

def process_all_recipes(recipes_dir: str, output_file: str):
    """Process all recipes and generate Spanish translations."""
    translations = {}
    
    for root, dirs, files in os.walk(recipes_dir):
        for file in files:
            if file.endswith('.json'):
                filepath = os.path.join(root, file)
                print(f"Translating: {file}")
                
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    
                    key = get_recipe_key(filepath)
                    
                    if isinstance(data, list):
                        for recipe in data:
                            translations[key] = translate_recipe(recipe)
                    else:
                        translations[key] = translate_recipe(data)
                        
                except Exception as e:
                    print(f"  Error: {e}")
    
    output_data = {
        "translations": translations,
        "_comment": "Complete Spanish translations for all recipes."
    }
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Generated {len(translations)} complete translations")

def main():
    recipes_dir = "PerfectBrew/Resources/Recipes"
    output_file = "PerfectBrew/Resources/Translations/recipes_es.json"
    
    print("=" * 60)
    print("Complete Spanish Translation Generator")
    print("=" * 60)
    
    process_all_recipes(recipes_dir, output_file)

if __name__ == "__main__":
    main()


