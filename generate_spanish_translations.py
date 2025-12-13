#!/usr/bin/env python3
"""
generate_spanish_translations.py

Generates Spanish translations for all PerfectBrew recipes.
Reads English recipes and creates corresponding Spanish versions.
"""

import json
import os
import re
from typing import Dict, List, Any

# Base translations for common brewing terms
BREWING_TERMS = {
    "Pour": "Vierte",
    "Stir": "Revuelve",
    "Wait": "Espera",
    "Let": "Deja",
    "Start": "Inicia",
    "Stop": "Detén",
    "Press": "Presiona",
    "Bloom": "Bloom",
    "Swirl": "Agita suavemente",
    "Add": "Añade",
    "Place": "Coloca",
    "Insert": "Inserta",
    "Remove": "Retira",
    "Grind": "Muele",
    "Heat": "Calienta",
    "Rinse": "Enjuaga",
    "Filter": "Filtro",
    "Coffee": "café",
    "Water": "agua",
    "Hot water": "agua caliente",
    "Grounds": "molido",
    "Timer": "cronómetro",
    "Cup": "taza",
    "Server": "servidor",
    "Kettle": "hervidor",
    "Scale": "báscula",
    "Plunger": "émbolo",
    "seconds": "segundos",
    "minutes": "minutos",
    "grams": "gramos",
    "evenly": "uniformemente",
    "slowly": "lentamente",
    "gently": "suavemente",
    "immediately": "inmediatamente",
}

def translate_recipe(recipe: Dict[str, Any], recipe_key: str) -> Dict[str, Any]:
    """Generate Spanish translation for a recipe."""
    translation = {}
    
    # Title translation
    title = recipe.get('title', '')
    translation['title_es'] = translate_title(title)
    
    # Notes translation
    notes = recipe.get('notes', '')
    if notes:
        translation['notes_es'] = translate_notes(notes, recipe.get('brewing_method', ''))
    
    # Preparation steps
    prep_steps = recipe.get('preparation_steps', [])
    if prep_steps:
        translation['preparation_steps_es'] = [translate_instruction(step) for step in prep_steps]
    
    # Brewing steps
    brewing_steps = recipe.get('brewing_steps', [])
    if brewing_steps:
        translation['brewing_steps'] = []
        for i, step in enumerate(brewing_steps):
            step_trans = {}
            if step.get('instruction'):
                step_trans['instruction_es'] = translate_instruction(step['instruction'])
            if step.get('short_instruction'):
                step_trans['short_instruction_es'] = translate_short_instruction(step['short_instruction'])
            if step.get('audio_script'):
                step_trans['audio_script_es'] = translate_audio_script(step['audio_script'])
            step_trans['time_seconds'] = step.get('time_seconds', 0)
            translation['brewing_steps'].append(step_trans)
    
    # What to expect
    wte = recipe.get('what_to_expect', {})
    if wte and isinstance(wte, dict):
        translation['what_to_expect'] = {}
        if wte.get('description'):
            translation['what_to_expect']['description_es'] = translate_description(wte['description'])
        if wte.get('audio_script'):
            translation['what_to_expect']['audio_script_es'] = translate_audio_script(wte['audio_script'])
    
    return translation

def translate_title(title: str) -> str:
    """Translate recipe title to Spanish."""
    # Keep method names and proper names, translate common words
    title_es = title
    
    # Common title translations
    replacements = {
        "Ultimate": "Definitivo",
        "Classic": "Clásico",
        "Single Serve": "Individual",
        "single serve": "individual",
        "Method": "Método",
        "Technique": "Técnica",
        "Recipe": "Receta",
        "Standard": "Estándar",
        "Extended": "Extendido",
        "Slow": "Lento",
        "Quick": "Rápido",
        "Morning": "Mañanero",
        "Everyday": "Diario",
        "Gentle": "Suave",
        "Scaled": "Escalado",
        "Light Roast": "Tueste Claro",
        "World Champion": "Campeón Mundial",
        "Concentrate": "Concentrado",
        "Championship": "Campeonato",
        "Single Cup": "Taza Individual",
        "Cup of Joy": "Taza de Alegría",
        "Bypass Americano": "Americano Bypass",
        "Espresso Style": "Estilo Espresso",
        "Strength Focus": "Enfoque en Intensidad",
        "Original": "Original",
        "Micro Dose": "Micro Dosis",
        "Two Cup": "Dos Tazas",
        "Small Batch": "Pequeña Producción",
    }
    
    for eng, esp in replacements.items():
        title_es = title_es.replace(eng, esp)
    
    return title_es

def translate_instruction(instruction: str) -> str:
    """Translate brewing instruction to Spanish - comprehensive word-by-word."""
    instruction_es = instruction
    
    # Order matters - more specific patterns first
    patterns = [
        # Full phrases first
        (r"Start timer and pour", "Inicia el cronómetro y vierte"),
        (r"Start your timer", "Inicia tu cronómetro"),
        (r"Start timer", "Inicia el cronómetro"),
        (r"Stop when you hear", "Detente cuando escuches"),
        (r"stop when you hear", "detente cuando escuches"),
        (r"Enjoy your coffee", "Disfruta tu café"),
        (r"Let the coffee steep", "Deja que el café repose"),
        (r"Let coffee steep", "Deja que el café repose"),
        (r"Let the coffee rest", "Deja que el café repose"),
        (r"Let rest", "Deja reposar"),
        (r"Let it rest", "Déjalo reposar"),
        (r"Let the coffee bloom", "Deja que el café haga bloom"),
        (r"coffee slurry", "mezcla de café"),
        (r"coffee bed", "cama de café"),
        (r"flat bed", "cama nivelada"),
        (r"partial vacuum seal", "sello de vacío parcial"),
        (r"vacuum seal", "sello de vacío"),
        (r"First Main Pour", "Primer Vertido Principal"),
        (r"Second Main Pour", "Segundo Vertido Principal"),
        (r"First phase", "Primera fase"),
        (r"Second phase", "Segunda fase"),
        (r"Third phase", "Tercera fase"),
        (r"hissing sound", "el silbido"),
        (r"soft hiss", "silbido suave"),
        (r"in circular motion", "en movimiento circular"),
        (r"circular motion", "movimiento circular"),
        (r"working your way outward", "avanzando hacia afuera"),
        (r"from the center", "desde el centro"),
        (r"all grounds", "todo el molido"),
        (r"all the grounds", "todo el molido"),
        (r"the grounds", "el molido"),
        (r"wet all", "moja todo"),
        
        # Pour patterns
        (r"Pour (\d+)\s*g(?:rams)?\s*(?:of\s*)?(?:hot\s*)?water\s*evenly", r"Vierte \1g de agua caliente uniformemente"),
        (r"Pour (\d+)\s*g(?:rams)?\s*(?:of\s*)?(?:hot\s*)?water", r"Vierte \1g de agua caliente"),
        (r"Pour up to (\d+)\s*g(?:rams)?", r"Vierte hasta \1g"),
        (r"Pour about (\d+)g", r"Vierte aproximadamente \1g"),
        (r"pour (\d+)g", r"vierte \1g"),
        (r"Pour evenly", "Vierte uniformemente"),
        (r"Pour slowly", "Vierte lentamente"),
        (r"pour immediately", "sirve inmediatamente"),
        (r"Pour immediately", "Sirve inmediatamente"),
        
        # Time patterns
        (r"Wait (\d+) seconds", r"Espera \1 segundos"),
        (r"Wait (\d+) minutes", r"Espera \1 minutos"),
        (r"wait (\d+) seconds", r"espera \1 segundos"),
        (r"Wait until", "Espera hasta"),
        (r"wait until", "espera hasta"),
        (r"about (\d+) seconds", r"aproximadamente \1 segundos"),
        (r"within (\d+) seconds", r"en \1 segundos"),
        (r"for (\d+) seconds", r"durante \1 segundos"),
        (r"for (\d+) minutes", r"durante \1 minutos"),
        (r"(\d+) seconds", r"\1 segundos"),
        (r"(\d+) minutes", r"\1 minutos"),
        
        # Action verbs
        (r"Stir gently", "Revuelve suavemente"),
        (r"stir gently", "revuelve suavemente"),
        (r"Stir clockwise", "Revuelve en sentido horario"),
        (r"Stir anticlockwise", "Revuelve en sentido antihorario"),
        (r"Stir", "Revuelve"),
        (r"stir", "revuelve"),
        (r"Gently swirl", "Agita suavemente"),
        (r"gently swirl", "agita suavemente"),
        (r"Swirl gently", "Agita suavemente"),
        (r"Swirl the brewer", "Agita el preparador"),
        (r"Swirl to flatten", "Agita para nivelar"),
        (r"Swirl", "Agita"),
        (r"swirl", "agita"),
        (r"Place the lid", "Coloca la tapa"),
        (r"Place lid", "Coloca la tapa"),
        (r"Place the filter", "Coloca el filtro"),
        (r"Place filter", "Coloca el filtro"),
        (r"Insert plunger", "Inserta el émbolo"),
        (r"insert plunger", "inserta el émbolo"),
        (r"Press the plunger", "Presiona el émbolo"),
        (r"Press plunger", "Presiona el émbolo"),
        (r"press the plunger", "presiona el émbolo"),
        (r"Press down slowly", "Presiona lentamente hacia abajo"),
        (r"slow, steady press", "presión lenta y constante"),
        (r"Slow, steady press", "Presión lenta y constante"),
        (r"do not press", "no presiones"),
        (r"Do not press", "No presiones"),
        (r"do not disturb", "no muevas"),
        (r"Do not disturb", "No muevas"),
        
        # Bloom
        (r"Bloom \(([^)]+)\):", r"Bloom (\1):"),
        (r"Bloom continues", "El bloom continúa"),
        (r"bloom continues", "el bloom continúa"),
        (r"bloom period", "período de bloom"),
        
        # Common phrases
        (r"This ensures", "Esto asegura"),
        (r"This helps", "Esto ayuda"),
        (r"This allows", "Esto permite"),
        (r"This breaks", "Esto rompe"),
        (r"This dislodges", "Esto desprende"),
        (r"create a", "crea un"),
        (r"Create a", "Crea un"),
        (r"aim for", "apunta a"),
        (r"Aim for", "Apunta a"),
        (r"aim to", "intenta"),
        (r"Aim to", "Intenta"),
        
        # Nouns and adjectives
        (r"hot water", "agua caliente"),
        (r"Hot water", "Agua caliente"),
        (r"water", "agua"),
        (r"coffee", "café"),
        (r"Coffee", "Café"),
        (r"grounds", "molido"),
        (r"timer", "cronómetro"),
        (r"Timer", "Cronómetro"),
        (r"cup", "taza"),
        (r"Cup", "Taza"),
        (r"server", "servidor"),
        (r"Server", "Servidor"),
        (r"plunger", "émbolo"),
        (r"Plunger", "Émbolo"),
        (r"lid", "tapa"),
        (r"Lid", "Tapa"),
        (r"filter", "filtro"),
        (r"Filter", "Filtro"),
        (r"brewer", "preparador"),
        (r"Brewer", "Preparador"),
        (r"scale", "báscula"),
        (r"Scale", "Báscula"),
        (r"kettle", "hervidor"),
        (r"Kettle", "Hervidor"),
        (r"spoon", "cuchara"),
        (r"Spoon", "Cuchara"),
        
        # Adverbs
        (r"evenly", "uniformemente"),
        (r"Evenly", "Uniformemente"),
        (r"slowly", "lentamente"),
        (r"Slowly", "Lentamente"),
        (r"gently", "suavemente"),
        (r"Gently", "Suavemente"),
        (r"immediately", "inmediatamente"),
        (r"Immediately", "Inmediatamente"),
        (r"steadily", "constantemente"),
        (r"Steadily", "Constantemente"),
        
        # Technical terms
        (r"de-gassing", "desgasificación"),
        (r"degassing", "desgasificación"),
        (r"extraction", "extracción"),
        (r"Extraction", "Extracción"),
        (r"saturate", "saturar"),
        (r"saturated", "saturado"),
        (r"saturation", "saturación"),
        
        # Additional common words
        (r"until", "hasta"),
        (r"Until", "Hasta"),
        (r"then", "luego"),
        (r"Then", "Luego"),
        (r"now", "ahora"),
        (r"Now", "Ahora"),
        (r"about", "aproximadamente"),
        (r"About", "Aproximadamente"),
        (r"total", "total"),
        (r"Total", "Total"),
        (r"complete", "completo"),
        (r"Complete", "Completo"),
        (r"even", "uniforme"),
        (r"Even", "Uniforme"),
        (r"all", "todo"),
        (r"All", "Todo"),
        (r"the", "el"),
        (r"The", "El"),
        (r"a ", "un "),
        (r"A ", "Un "),
        (r"to ", "para "),
        (r"To ", "Para "),
        (r"and", "y"),
        (r"And", "Y"),
        (r"or", "o"),
        (r"Or", "O"),
        (r"with", "con"),
        (r"With", "Con"),
        (r"on", "sobre"),
        (r"On", "Sobre"),
        (r"over", "sobre"),
        (r"Over", "Sobre"),
        (r"into", "en"),
        (r"Into", "En"),
        (r"this", "esto"),
        (r"This", "Esto"),
        (r"that", "eso"),
        (r"That", "Eso"),
        (r"is", "es"),
        (r"Is", "Es"),
        (r"are", "son"),
        (r"Are", "Son"),
        (r"will", "va"),
        (r"Will", "Va"),
        (r"can", "puede"),
        (r"Can", "Puede"),
        (r"your", "tu"),
        (r"Your", "Tu"),
        (r"you", "tú"),
        (r"You", "Tú"),
    ]
    
    for pattern, replacement in patterns:
        instruction_es = re.sub(pattern, replacement, instruction_es, flags=re.IGNORECASE if pattern[0].islower() else 0)
    
    return instruction_es

def translate_short_instruction(short_inst: str) -> str:
    """Translate short instruction to Spanish."""
    short_inst_es = short_inst
    
    patterns = [
        (r"Pour (\d+)g", r"Vierte \1g"),
        (r"Bloom", "Bloom"),
        (r"Stir", "Revuelve"),
        (r"Swirl", "Agita"),
        (r"Wait", "Espera"),
        (r"Press", "Presiona"),
        (r"Let rest", "Deja reposar"),
        (r"Let bloom", "Deja hacer bloom"),
        (r"Let steep", "Deja reposar"),
        (r"Do not press", "No presiones"),
        (r"Start timer", "Inicia cronómetro"),
        (r"Create vacuum", "Crea vacío"),
        (r"Insert plunger", "Inserta émbolo"),
        (r"Place lid", "Coloca tapa"),
        (r"hot water evenly", "agua caliente uniformemente"),
        (r"seconds", "seg"),
        (r"minutes", "min"),
        (r"until", "hasta"),
        (r"within", "en"),
        (r"slowly", "lentamente"),
        (r"gently", "suavemente"),
        (r"immediately", "inmediatamente"),
        (r"flatten bed", "nivela cama"),
        (r"clockwise", "horario"),
        (r"anticlockwise", "antihorario"),
        (r"pour", "sirve"),
    ]
    
    for pattern, replacement in patterns:
        short_inst_es = re.sub(pattern, replacement, short_inst_es, flags=re.IGNORECASE)
    
    return short_inst_es

def translate_audio_script(script: str) -> str:
    """Translate audio script to Spanish."""
    script_es = translate_instruction(script)
    
    # Additional audio-specific translations
    patterns = [
        (r"You have (\d+) seconds?", r"Tienes \1 segundos"),
        (r"Now ", "Ahora "),
        (r"Finally,", "Finalmente,"),
        (r"It's time to", "Es hora de"),
        (r"Take a spoon", "Toma una cuchara"),
        (r"Hold (both )?the", "Sostén"),
        (r"Apply", "Aplica"),
        (r"Don't rush", "No te apresures"),
        (r"Once pressed", "Una vez presionado"),
        (r"to stop the brewing", "para detener la preparación"),
        (r"to ensure", "para asegurar"),
        (r"This breaks", "Esto rompe"),
        (r"This dislodges", "Esto desprende"),
        (r"the crust", "la costra"),
        (r"sinks the grounds", "hunde el molido"),
        (r"settle back down", "se asienten"),
        (r"cleaner cup", "taza más limpia"),
        (r"complete saturation", "saturación completa"),
        (r"uniform extraction", "extracción uniforme"),
        (r"even extraction", "extracción uniforme"),
        (r"optimal extraction", "extracción óptima"),
        (r"full extraction", "extracción completa"),
        (r"steady flow", "flujo constante"),
        (r"steady pressure", "presión constante"),
        (r"working your way", "avanzando"),
        (r"from the center", "desde el centro"),
        (r"outward", "hacia afuera"),
        (r"about (\d+) revolutions?", r"aproximadamente \1 vueltas"),
        (r"each way", "en cada dirección"),
        (r"the whole setup", "todo el conjunto"),
        (r"both.*and.*together", "ambos juntos"),
        (r"securely", "firmemente"),
        (r"coffee particles", "partículas de café"),
        (r"soluble flavors", "sabores solubles"),
        (r"rich, heavy body", "cuerpo rico y denso"),
        (r"full-bodied", "con cuerpo completo"),
    ]
    
    for pattern, replacement in patterns:
        script_es = re.sub(pattern, replacement, script_es, flags=re.IGNORECASE)
    
    return script_es

def translate_description(description: str) -> str:
    """Translate what_to_expect description to Spanish."""
    desc_es = description
    
    patterns = [
        (r"Expect a", "Espera una"),
        (r"expect a", "espera una"),
        (r"This (method|technique|recipe)", r"Este \1"),
        (r"method", "método"),
        (r"technique", "técnica"),
        (r"recipe", "receta"),
        (r"clean cup", "taza limpia"),
        (r"balanced cup", "taza equilibrada"),
        (r"bright cup", "taza brillante"),
        (r"smooth cup", "taza suave"),
        (r"full-bodied cup", "taza con cuerpo completo"),
        (r"with good body", "con buen cuerpo"),
        (r"with excellent clarity", "con excelente claridad"),
        (r"balanced acidity", "acidez equilibrada"),
        (r"bright acidity", "acidez brillante"),
        (r"subtle sweetness", "dulzura sutil"),
        (r"origin characteristics", "características de origen"),
        (r"natural characteristics", "características naturales"),
        (r"roast levels?", "niveles de tueste"),
        (r"light to medium", "claro a medio"),
        (r"medium to dark", "medio a oscuro"),
        (r"lighter roasts?", "tuestes claros"),
        (r"darker roasts?", "tuestes oscuros"),
        (r"works (exceptionally )?well", "funciona muy bien"),
        (r"perfect for", "perfecto para"),
        (r"ideal for", "ideal para"),
        (r"daily brewing", "preparación diaria"),
        (r"everyday brewing", "preparación diaria"),
        (r"simplicity", "simplicidad"),
        (r"consistency", "consistencia"),
        (r"precision", "precisión"),
        (r"control", "control"),
        (r"minimal sediment", "sedimento mínimo"),
        (r"minimal complexity", "complejidad mínima"),
        (r"maximum reproducibility", "máxima reproducibilidad"),
        (r"temperature stability", "estabilidad de temperatura"),
        (r"refined approach", "enfoque refinado"),
        (r"unique technique", "técnica única"),
        (r"strategic", "estratégico"),
        (r"approachability", "accesibilidad"),
        (r"highlighting", "resaltando"),
        (r"emphasizes", "enfatiza"),
        (r"prioritizes", "prioriza"),
        (r"produces", "produce"),
        (r"creates", "crea"),
        (r"allows for", "permite"),
        (r"resulting in", "resultando en"),
        (r"offering", "ofreciendo"),
        (r"maintaining", "manteniendo"),
        (r"ensuring", "asegurando"),
        (r"avoiding", "evitando"),
        (r"over-extraction", "sobre-extracción"),
        (r"under-extraction", "sub-extracción"),
        (r"between (\d+).*?(\d+).*?C", r"entre \1 y \2 grados Celsius"),
        (r"(\d+)°C", r"\1°C"),
        (r"Celsius", "Celsius"),
        (r"degrees", "grados"),
    ]
    
    for pattern, replacement in patterns:
        desc_es = re.sub(pattern, replacement, desc_es, flags=re.IGNORECASE)
    
    return desc_es

def translate_notes(notes: str, method: str) -> str:
    """Translate notes to Spanish."""
    return translate_description(notes)

def get_recipe_key_from_path(filepath: str) -> str:
    """Extract recipe key from file path."""
    filename = os.path.basename(filepath)
    return filename.replace('.json', '')

def process_all_recipes(recipes_dir: str, output_file: str):
    """Process all recipe files and generate Spanish translations."""
    translations = {}
    
    for root, dirs, files in os.walk(recipes_dir):
        for file in files:
            if file.endswith('.json'):
                filepath = os.path.join(root, file)
                print(f"Processing: {filepath}")
                
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    
                    # Handle array of recipes
                    if isinstance(data, list):
                        for recipe in data:
                            key = get_recipe_key_from_path(filepath)
                            translations[key] = translate_recipe(recipe, key)
                    else:
                        key = get_recipe_key_from_path(filepath)
                        translations[key] = translate_recipe(data, key)
                        
                except Exception as e:
                    print(f"  Error: {e}")
    
    # Write translations
    output_data = {
        "translations": translations,
        "_comment": "Auto-generated Spanish translations. Review and refine as needed."
    }
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Generated {len(translations)} translations to {output_file}")

def main():
    recipes_dir = "PerfectBrew/Resources/Recipes"
    output_file = "PerfectBrew/Resources/Translations/recipes_es.json"
    
    print("=" * 60)
    print("Spanish Translation Generator for PerfectBrew")
    print("=" * 60)
    
    process_all_recipes(recipes_dir, output_file)

if __name__ == "__main__":
    main()

