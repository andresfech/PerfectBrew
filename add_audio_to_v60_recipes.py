#!/usr/bin/env python3
"""
Script para agregar audio_file_name a las recetas V60
"""

import json
import os

def add_audio_to_v60_recipes():
    """Agregar audio_file_name a todas las recetas V60"""
    
    file_path = "PerfectBrew/Resources/recipes_v60.json"
    
    # Cargar recetas
    with open(file_path, 'r', encoding='utf-8') as f:
        recipes = json.load(f)
    
    print(f"📖 Cargando {len(recipes)} recetas V60...")
    
    # Mapeo de títulos a nombres de carpeta
    title_to_folder = {
        "Kaldi's Coffee - Single Serve": "Kaldi_Coffee_Single_Serve",
        "Kaldi's Coffee - Two People": "Kaldi_Coffee_Two_People", 
        "Kaldi's Coffee - Three People": "Kaldi_Coffee_Three_People",
        "James Hoffmann V60 - Single Serve": "James_Hoffmann_V60_Single_Serve",
        "James Hoffmann V60 - Two People": "James_Hoffmann_V60_Two_People",
        "James Hoffmann V60 - Three People": "James_Hoffmann_V60_Three_People",
        "James Hoffmann V60 - Four People": "James_Hoffmann_V60_Four_People",
        "Scott Rao V60 - Two People": "Scott_Rao_V60_Two_People",
        "Scott Rao V60 - Three People": "Scott_Rao_V60_Three_People",
        "Scott Rao V60 - Four People": "Scott_Rao_V60_Four_People",
        "Quick Morning V60": "Quick_Morning_V60"
    }
    
    updated_recipes = []
    
    for recipe in recipes:
        title = recipe['title']
        print(f"\n🎯 Procesando: {title}")
        
        # Obtener nombre de carpeta
        folder_name = title_to_folder.get(title, title.replace(' ', '_').replace('/', '_'))
        
        # Agregar audio_file_name a pasos de preparación
        if 'preparation_steps' in recipe:
            # Los pasos de preparación no tienen audio individual, se saltan
            pass
        
        # Agregar audio_file_name a pasos de preparación
        if 'brewing_steps' in recipe:
            for i, step in enumerate(recipe['brewing_steps'], 1):
                # Determinar el prefijo basado en el título
                if "Single Serve" in title:
                    prefix = "single_serve"
                elif "Two People" in title:
                    prefix = "two_people"
                elif "Three People" in title:
                    prefix = "three_people"
                elif "Four People" in title:
                    prefix = "four_people"
                else:
                    prefix = "v60"
                
                # Agregar audio_file_name
                step['audio_file_name'] = f"{prefix}_brewing_step_{i:02d}.wav"
                print(f"   ✅ Paso {i}: {step['audio_file_name']}")
        
        updated_recipes.append(recipe)
    
    # Guardar recetas actualizadas
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(updated_recipes, f, indent=2, ensure_ascii=False)
    
    print(f"\n🎉 Audio agregado a {len(updated_recipes)} recetas V60")
    print(f"📁 Archivo actualizado: {file_path}")

if __name__ == "__main__":
    add_audio_to_v60_recipes()
